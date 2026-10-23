import path from 'node:path';
import { z } from 'zod';
import { JsonStore } from '../storage/jsonStore.js';
import { FavoriteRecord, favoriteRecordSchema } from '../domain/quote.js';

export interface FavoriteRepository {
  isFavorite(userId: string, quoteId: string): Promise<boolean>;
  addFavorite(userId: string, quoteId: string): Promise<void>;
  removeFavorite(userId: string, quoteId: string): Promise<void>;
  listFavorites(userId: string): Promise<FavoriteRecord[]>;
}

const favoritesArraySchema = z.array(favoriteRecordSchema);

export class JsonFavoriteRepository implements FavoriteRepository {
  private store: JsonStore<FavoriteRecord[]>;

  constructor(customStoreOrPath?: JsonStore<FavoriteRecord[]> | string) {
    if (customStoreOrPath instanceof JsonStore) {
      this.store = customStoreOrPath;
    } else {
      const filePath =
        typeof customStoreOrPath === 'string'
          ? customStoreOrPath
          : path.resolve(process.cwd(), 'data/favorites.json');

      this.store = new JsonStore<FavoriteRecord[]>({
        filePath,
        schema: favoritesArraySchema,
        defaultValue: []
      });
    }
  }

  public async isFavorite(userId: string, quoteId: string): Promise<boolean> {
    const list = await this.store.read();
    return list.some((f) => f.userId === userId && f.quoteId === quoteId);
  }

  public async addFavorite(userId: string, quoteId: string): Promise<void> {
    await this.store.update((list) => {
      const exists = list.some((f) => f.userId === userId && f.quoteId === quoteId);
      if (exists) {
        return list;
      }
      return [
        ...list,
        {
          userId,
          quoteId,
          createdAt: new Date().toISOString()
        }
      ];
    });
  }

  public async removeFavorite(userId: string, quoteId: string): Promise<void> {
    await this.store.update((list) =>
      list.filter((f) => !(f.userId === userId && f.quoteId === quoteId))
    );
  }

  public async listFavorites(userId: string): Promise<FavoriteRecord[]> {
    const list = await this.store.read();
    return list.filter((f) => f.userId === userId).map((f) => ({ ...f }));
  }
}
