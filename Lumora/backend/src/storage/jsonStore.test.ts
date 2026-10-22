import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import fs from 'node:fs';
import path from 'node:path';
import { z } from 'zod';
import { JsonStore } from './jsonStore.js';

describe('JsonStore', () => {
  const testDir = path.resolve(__dirname, '../../test_tmp_data');
  const testFile = path.join(testDir, 'test_store.json');
  const backupDir = path.join(testDir, 'backup');

  beforeEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
    await fs.promises.mkdir(testDir, { recursive: true });
  });

  afterEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
  });

  it('eşzamanlı 50 yazmanın birbirini ezmemesi (mutex kuyruğu doğrulaması)', async () => {
    const schema = z.array(z.number());
    const store = new JsonStore<number[]>({
      filePath: testFile,
      schema,
      defaultValue: [],
      backupBaseDir: backupDir
    });

    // Başlangıçta boş dizi
    await store.read();

    // 50 eşzamanlı güncelleme başlat
    const updates = Array.from({ length: 50 }, (_, i) =>
      store.update((list) => [...list, i])
    );

    await Promise.all(updates);

    // Diskten ve bellekten sonucu oku
    const result = await store.read();
    expect(result).toHaveLength(50);

    // Tüm sayıların (0-49) eksiksiz yer aldığını doğrula
    const sorted = [...result].sort((a, b) => a - b);
    expect(sorted).toEqual(Array.from({ length: 50 }, (_, i) => i));

    // Dosyayı doğrudan diskten okuyup JSON içeriğinin de 50 eleman olduğunu doğrula
    const diskContent = JSON.parse(await fs.promises.readFile(testFile, 'utf-8'));
    expect(diskContent).toHaveLength(50);
  });

  it('yazma sırasında çökme simülasyonunda ana dosyanın bozulmaması', async () => {
    const schema = z.object({ counter: z.number() });
    const store = new JsonStore<{ counter: number }>({
      filePath: testFile,
      schema,
      defaultValue: { counter: 10 },
      backupBaseDir: backupDir
    });

    // Başlangıç verisini yaz ve doğrula
    await store.write({ counter: 10 });
    const initialContent = await fs.promises.readFile(testFile, 'utf-8');
    expect(JSON.parse(initialContent)).toEqual({ counter: 10 });

    // Çökme simülasyonu: rename işleminden önce yazma kesintiye uğrarsa veya hata fırlatılırsa
    // Orijinal rename fonksiyonunu mocklayarak hata fırlatıyoruz
    const originalRename = fs.promises.rename;
    fs.promises.rename = async () => {
      throw new Error('SİSTEM ÇÖKMESİ SİMÜLASYONU: Elektrik kesintisi / disk yazma hatası');
    };

    try {
      await expect(store.write({ counter: 999 })).rejects.toThrow('SİSTEM ÇÖKMESİ SİMÜLASYONU');
    } finally {
      // Mock'u geri al
      fs.promises.rename = originalRename;
    }

    // Önbelleği temizle ve diskteki dosyayı yeniden oku
    store.clearCache();
    const recoveredData = await store.read();

    // Ana dosyanın bozulmadığı ve 10 değerini koruduğu doğrulanır
    expect(recoveredData).toEqual({ counter: 10 });
    const rawDisk = JSON.parse(await fs.promises.readFile(testFile, 'utf-8'));
    expect(rawDisk).toEqual({ counter: 10 });
  });

  it('bozuk dosyada anlaşılır hata ve .bak önerisi vermesi (geçersiz JSON)', async () => {
    const schema = z.object({ name: z.string() });
    const store = new JsonStore<{ name: string }>({
      filePath: testFile,
      schema,
      backupBaseDir: backupDir
    });

    // Dosyaya bozuk / yarım JSON içeriği yaz
    await fs.promises.writeFile(testFile, '{"name": "Lumora", broken json...', 'utf-8');

    await expect(store.read()).rejects.toThrow(/Bozuk dosya tespit edildi.*\.bak yedeğini kontrol edin/);
  });

  it('bozuk dosyada anlaşılır hata ve .bak önerisi vermesi (şema uyumsuzluğu)', async () => {
    const schema = z.object({
      id: z.string(),
      count: z.number()
    });

    const store = new JsonStore<{ id: string; count: number }>({
      filePath: testFile,
      schema,
      backupBaseDir: backupDir
    });

    // Geçerli JSON ama şemaya uymayan veri (count yerine string verilmiş)
    await fs.promises.writeFile(testFile, JSON.stringify({ id: 'abc', count: 'yuz' }), 'utf-8');

    await expect(store.read()).rejects.toThrow(/Şema doğrulama başarısız.*\.bak yedeğini kontrol edin/);
  });

  it('günün ilk yazmasında yedek klasörü oluşturması', async () => {
    const schema = z.object({ value: z.string() });
    const store = new JsonStore<{ value: string }>({
      filePath: testFile,
      schema,
      backupBaseDir: backupDir
    });

    await store.write({ value: 'v1' });
    // İkinci yazmada bugünün yedeği kontrol edilir
    await store.write({ value: 'v2' });

    const today = new Date().toISOString().slice(0, 10);
    const backupFilePath = path.join(backupDir, today, path.basename(testFile));
    expect(fs.existsSync(backupFilePath)).toBe(true);

    const backupContent = JSON.parse(await fs.promises.readFile(backupFilePath, 'utf-8'));
    expect(backupContent).toEqual({ value: 'v1' });
  });
});
