import fs from 'node:fs';
import path from 'node:path';
import { z } from 'zod';

export interface JsonStoreOptions<T> {
  filePath: string;
  schema: z.ZodType<T, z.ZodTypeDef, any>;
  defaultValue?: T;
  backupBaseDir?: string;
}

/**
 * JsonStore: Güvenli, atomik, mutex kuyruklu ve yedeklemeli JSON dosya deposu.
 * Mimari Kuralı: JSON depolama tek bir Node.js sürecinde güvenlidir.
 */
export class JsonStore<T> {
  private filePath: string;
  private schema: z.ZodType<T, z.ZodTypeDef, any>;
  private defaultValue?: T;
  private backupBaseDir: string;
  private cache: T | null = null;
  private writeQueue: Promise<unknown> = Promise.resolve();
  private lastBackupDate: string = '';

  constructor(options: JsonStoreOptions<T>) {
    this.filePath = path.resolve(options.filePath);
    this.schema = options.schema;
    this.defaultValue = options.defaultValue;
    this.backupBaseDir = options.backupBaseDir
      ? path.resolve(options.backupBaseDir)
      : path.join(path.dirname(this.filePath), 'backup');
  }

  public getFilePath(): string {
    return this.filePath;
  }

  public clearCache(): void {
    this.cache = null;
  }

  /**
   * Dosyayı okur; varsa bellek önbelleğinden döndürür, yoksa diskten okuyup doğrular.
   */
  public async read(): Promise<T> {
    if (this.cache !== null) {
      return this.cache;
    }

    if (!fs.existsSync(this.filePath)) {
      if (this.defaultValue !== undefined) {
        await this.internalWrite(this.defaultValue);
        return this.defaultValue;
      }
      throw new Error(`Dosya bulunamadı: ${this.filePath}`);
    }

    let rawContent: string;
    try {
      rawContent = await fs.promises.readFile(this.filePath, 'utf-8');
    } catch {
      throw new Error(`Dosya okunamadı: ${this.filePath}. Lütfen ${this.filePath}.bak yedeğini kontrol edin.`);
    }

    let parsedJson: unknown;
    try {
      parsedJson = JSON.parse(rawContent);
    } catch {
      throw new Error(
        `Bozuk dosya tespit edildi: ${this.filePath}. JSON ayrıştırılamadı. Lütfen ${this.filePath}.bak yedeğini kontrol edin.`
      );
    }

    const validation = this.schema.safeParse(parsedJson);
    if (!validation.success) {
      throw new Error(
        `Bozuk dosya tespit edildi: ${this.filePath}. Şema doğrulama başarısız. Lütfen ${this.filePath}.bak yedeğini kontrol edin.`
      );
    }

    this.cache = validation.data;
    return this.cache;
  }

  /**
   * Günün ilk yazmasında dosyanın yedeğini data/backup/<YYYY-MM-DD>/ altına alır.
   * 7 günden eski yedek klasörlerini temizler.
   */
  private async performDailyBackup(): Promise<void> {
    const today = new Date().toISOString().slice(0, 10);
    if (this.lastBackupDate === today) {
      return;
    }

    if (!fs.existsSync(this.filePath)) {
      return;
    }

    const targetDir = path.join(this.backupBaseDir, today);
    await fs.promises.mkdir(targetDir, { recursive: true });

    const fileName = path.basename(this.filePath);
    const destFile = path.join(targetDir, fileName);

    await fs.promises.copyFile(this.filePath, destFile);
    this.lastBackupDate = today;

    await this.pruneOldBackups();
  }

  private async pruneOldBackups(): Promise<void> {
    try {
      if (!fs.existsSync(this.backupBaseDir)) {
        return;
      }
      const entries = await fs.promises.readdir(this.backupBaseDir, { withFileTypes: true });
      const dateDirs = entries
        .filter((e) => e.isDirectory() && /^\d{4}-\d{2}-\d{2}$/.test(e.name))
        .map((e) => e.name)
        .sort();

      if (dateDirs.length > 7) {
        const toDelete = dateDirs.slice(0, dateDirs.length - 7);
        for (const dirName of toDelete) {
          await fs.promises.rm(path.join(this.backupBaseDir, dirName), { recursive: true, force: true });
        }
      }
    } catch (err) {
      console.warn('Backup pruning hatası:', err);
    }
  }

  /**
   * Atomik yazma: Önce geçici .tmp dosyasına yazar, sonra atomic rename ile hedef dosyanın yerine geçirir.
   */
  private async internalWrite(data: T): Promise<void> {
    const validation = this.schema.safeParse(data);
    if (!validation.success) {
      throw new Error(
        `Yazma sırasında şema doğrulama başarısız: ${this.filePath}. Lütfen ${this.filePath}.bak yedeğini kontrol edin.`
      );
    }

    const validData = validation.data;

    const dir = path.dirname(this.filePath);
    if (!fs.existsSync(dir)) {
      await fs.promises.mkdir(dir, { recursive: true });
    }

    await this.performDailyBackup();

    const tmpFilePath = `${this.filePath}.tmp.${Date.now()}.${Math.random().toString(36).slice(2, 8)}`;
    const jsonString = JSON.stringify(validData, null, 2);

    await fs.promises.writeFile(tmpFilePath, jsonString, 'utf-8');
    await fs.promises.rename(tmpFilePath, this.filePath);

    this.cache = validData;
  }

  /**
   * Mutex kuyruğu ile doğrudan yazma.
   */
  public async write(data: T): Promise<void> {
    const operation = async () => {
      await this.internalWrite(data);
    };

    const queued = this.writeQueue.then(operation, operation);
    this.writeQueue = queued;
    return queued;
  }

  /**
   * Mutex kuyruğu ile oku-değiştir-yaz (read-modify-write).
   * Eşzamanlı işlemlerde verilerin birbirini ezmesini engeller.
   */
  public async update(mutator: (current: T) => T | Promise<T>): Promise<T> {
    let result: T;
    const operation = async () => {
      const current = await this.read();
      const cloned = JSON.parse(JSON.stringify(current));
      const next = await mutator(cloned);
      await this.internalWrite(next);
      result = next;
      return next;
    };

    const queued = this.writeQueue.then(operation, operation);
    this.writeQueue = queued;
    await queued;
    return result!;
  }
}
