import path from 'node:path';
import { JsonStore } from '../storage/jsonStore.js';
import {
  createDefaultSettings,
  UserSettings,
  userSettingsArraySchema
} from '../domain/settings.js';

export interface UserSettingsRepository {
  getByUserId(userId: string): Promise<UserSettings>;
  update(userId: string, patch: Partial<UserSettings>): Promise<UserSettings>;
}

export class JsonUserSettingsRepository implements UserSettingsRepository {
  private store: JsonStore<UserSettings[]>;

  constructor(customStoreOrPath?: JsonStore<UserSettings[]> | string) {
    if (customStoreOrPath instanceof JsonStore) {
      this.store = customStoreOrPath;
    } else {
      const filePath =
        typeof customStoreOrPath === 'string'
          ? customStoreOrPath
          : path.resolve(process.cwd(), 'data/user_settings.json');

      this.store = new JsonStore<UserSettings[]>({
        filePath,
        schema: userSettingsArraySchema,
        defaultValue: []
      });
    }
  }

  public async getByUserId(userId: string): Promise<UserSettings> {
    const all = await this.store.read();
    const found = all.find((s) => s.userId === userId);
    if (found) {
      return { ...found };
    }

    // Kullanıcıya özel varsayılan ayar oluştur ve sakla
    const defaultSettings = createDefaultSettings(userId);
    await this.store.update((list) => {
      // Çift yazmayı önle
      if (list.some((s) => s.userId === userId)) return list;
      return [...list, defaultSettings];
    });

    return { ...defaultSettings };
  }

  public async update(
    userId: string,
    patch: Partial<UserSettings>
  ): Promise<UserSettings> {
    let result: UserSettings | null = null;

    await this.store.update((list) => {
      const index = list.findIndex((s) => s.userId === userId);
      if (index !== -1) {
        const merged = { ...list[index], ...patch, userId };
        list[index] = merged;
        result = merged;
      } else {
        const defaultSettings = createDefaultSettings(userId);
        const merged = { ...defaultSettings, ...patch, userId };
        list.push(merged);
        result = merged;
      }
      return list;
    });

    if (!result) {
      throw new Error(`Ayar güncellenemedi: ${userId}`);
    }

    return result;
  }
}
