import fs from 'node:fs';
import path from 'node:path';
import { z } from 'zod';
import { JsonStore } from '../storage/jsonStore.js';
import {
  DailyQuoteDto,
  Quote,
  quoteSchema,
  QuotesCache,
  quotesCacheSchema
} from '../domain/quote.js';
import { FavoriteRepository, JsonFavoriteRepository } from '../repositories/favoriteRepository.js';

export function getDeterministicIndex(seed: string, length: number): number {
  if (length <= 0) return 0;
  let hash = 0;
  for (let i = 0; i < seed.length; i++) {
    hash = (hash << 5) - hash + seed.charCodeAt(i);
    hash |= 0;
  }
  return Math.abs(hash) % length;
}

export interface QuoteServiceOptions {
  cacheStoreOrPath?: JsonStore<QuotesCache> | string;
  fallbackQuotesPath?: string;
  favoriteRepository?: FavoriteRepository;
}

export class QuoteService {
  private cacheStore: JsonStore<QuotesCache>;
  private fallbackQuotesPath: string;
  private favoriteRepository: FavoriteRepository;

  constructor(options?: QuoteServiceOptions) {
    if (options?.cacheStoreOrPath instanceof JsonStore) {
      this.cacheStore = options.cacheStoreOrPath;
    } else {
      const cachePath =
        typeof options?.cacheStoreOrPath === 'string'
          ? options.cacheStoreOrPath
          : path.resolve(process.cwd(), 'data/quotes_cache.json');

      this.cacheStore = new JsonStore<QuotesCache>({
        filePath: cachePath,
        schema: quotesCacheSchema,
        defaultValue: {
          generatedAt: '',
          language: 'tr',
          quotes: []
        }
      });
    }

    this.fallbackQuotesPath =
      options?.fallbackQuotesPath ??
      path.resolve(process.cwd(), 'seed/fallback_quotes.json');

    this.favoriteRepository =
      options?.favoriteRepository ?? new JsonFavoriteRepository();
  }

  /**
   * seed/fallback_quotes.json dosyasından yedek sözleri okur ve doğrular.
   */
  public async loadFallbackQuotes(): Promise<Quote[]> {
    if (!fs.existsSync(this.fallbackQuotesPath)) {
      throw new Error(`Yedek sözler dosyası bulunamadı: ${this.fallbackQuotesPath}`);
    }

    const content = await fs.promises.readFile(this.fallbackQuotesPath, 'utf-8');
    const parsed = JSON.parse(content);
    const validated = z.array(quoteSchema).parse(parsed);
    return validated;
  }

  /**
   * Günün söz havuzunu döndürür.
   * quotes_cache.json içinde o günün sözleri varsa oradan döner;
   * yoksa fallback_quotes.json'dan yükleyip cache'e yazar ve döner.
   */
  public async getDailyQuotesPool(dateStr: string): Promise<Quote[]> {
    const cached = await this.cacheStore.read();
    if (cached.generatedAt === dateStr && cached.quotes.length > 0) {
      return cached.quotes;
    }

    // Aşama 1: Fallback söz havuzunu yükle ve cache'e yaz
    const fallbackQuotes = await this.loadFallbackQuotes();
    const newCache: QuotesCache = {
      generatedAt: dateStr,
      language: 'tr',
      quotes: fallbackQuotes
    };
    await this.cacheStore.write(newCache);
    return fallbackQuotes;
  }

  /**
   * Günün sözünü tarih ve userId ile deterministik olarak seçer.
   * isFavorite durumunu da kontrol ederek DailyQuoteDto döner.
   */
  public async getDailyQuote(userId: string, targetDateStr?: string): Promise<DailyQuoteDto> {
    const dateStr = targetDateStr ?? new Date().toISOString().slice(0, 10);
    const pool = await this.getDailyQuotesPool(dateStr);

    if (pool.length === 0) {
      throw new Error('Söz havuzu boş, günün sözü seçilemedi.');
    }

    const index = getDeterministicIndex(`${dateStr}:${userId}`, pool.length);
    const selected = pool[index];

    const isFavorite = await this.favoriteRepository.isFavorite(userId, selected.id);

    return {
      ...selected,
      isFavorite
    };
  }

  public async addFavorite(userId: string, quoteId: string): Promise<void> {
    await this.favoriteRepository.addFavorite(userId, quoteId);
  }

  public async removeFavorite(userId: string, quoteId: string): Promise<void> {
    await this.favoriteRepository.removeFavorite(userId, quoteId);
  }

  public async isFavorite(userId: string, quoteId: string): Promise<boolean> {
    return this.favoriteRepository.isFavorite(userId, quoteId);
  }
}
