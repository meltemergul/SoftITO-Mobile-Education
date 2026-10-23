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
import { config } from '../config/index.js';

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
  hfToken?: string;
  hfModel?: string;
  hfTimeoutMs?: number;
}

export class QuoteService {
  private cacheStore: JsonStore<QuotesCache>;
  private fallbackQuotesPath: string;
  private favoriteRepository: FavoriteRepository;
  private hfToken: string;
  private hfModel: string;
  private hfTimeoutMs: number;

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

    this.hfToken = options?.hfToken ?? config.HF_TOKEN;
    this.hfModel = options?.hfModel ?? config.HF_MODEL;
    this.hfTimeoutMs = options?.hfTimeoutMs ?? config.HF_TIMEOUT_MS;
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
   * Hugging Face API üzerinden günün motivasyon sözünü üretir/çeker.
   * Model veya token hatası, timeout veya kota aşımında null döner (graceful fallback).
   */
  public async fetchHuggingFaceQuote(): Promise<Quote | null> {
    if (config.NODE_ENV === 'test' || !this.hfToken || this.hfToken === 'placeholder_hf_token') {
      return null;
    }

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), this.hfTimeoutMs);

      // 1. Yeni Router v1 /chat/completions endpointi dene (OpenAI compatible)
      try {
        const chatRes = await fetch('https://router.huggingface.co/v1/chat/completions', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${this.hfToken}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            model: this.hfModel,
            messages: [
              {
                role: 'system',
                content: 'Sen ilham verici, bilge bir motivasyon asistanısın. Türkçe, tek cümlelik, tırnaksız motivasyon sözü üret.'
              },
              {
                role: 'user',
                content: 'Alışkanlık takibi ve süreklilik için bugün için etkileyici ve ilham verici bir motivasyon sözü yaz. Sadece sözü döndür.'
              }
            ],
            max_tokens: 100,
            temperature: 0.7
          }),
          signal: controller.signal
        });

        if (chatRes.ok) {
          clearTimeout(timeoutId);
          const data = (await chatRes.json()) as { choices?: Array<{ message?: { content?: string } }> };
          const content = data.choices?.[0]?.message?.content?.trim();
          if (content && content.length > 5) {
            const cleanText = content.replace(/^["'“”«»]+|["'“”«»]+$/g, '').trim();
            console.log(`[QuoteService] Hugging Face Chat API söz üretti: "${cleanText}"`);
            return {
              id: `hf_${Date.now()}`,
              text: cleanText,
              author: 'AI Motivasyon',
              source: 'ai'
            };
          }
        } else {
          const errData = await chatRes.text();
          console.warn(`[QuoteService] Hugging Face Chat API hatası (${chatRes.status}):`, errData);
        }
      } catch (chatErr) {
        console.warn('[QuoteService] Hugging Face Chat API bağlantı denemesi başarısız:', (chatErr as Error)?.message || chatErr);
      }

      // 2. Serverless Inference API router.huggingface.co/hf-inference/models/<MODEL>
      const response = await fetch(`https://router.huggingface.co/hf-inference/models/${this.hfModel}`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.hfToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          inputs: 'Alışkanlık kazanmak ve hedefe ulaşmak için bugünün motivasyon sözü:',
          parameters: {
            max_new_tokens: 80,
            return_full_text: false,
            temperature: 0.7
          }
        }),
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        const errorBody = await response.text();
        console.warn(`[QuoteService] Hugging Face Serverless API hatası (${response.status}):`, errorBody);
        return null;
      }

      const result = await response.json();
      let generatedText = '';

      if (Array.isArray(result) && result[0]?.generated_text) {
        generatedText = String(result[0].generated_text).trim();
      } else if (typeof result === 'object' && result !== null && 'generated_text' in result) {
        generatedText = String((result as { generated_text: string }).generated_text).trim();
      }

      if (generatedText && generatedText.length > 5) {
        const cleanText = generatedText.replace(/^["'“”«»]+|["'“”«»]+$/g, '').trim();
        console.log(`[QuoteService] Hugging Face Serverless API söz üretti: "${cleanText}"`);
        return {
          id: `hf_${Date.now()}`,
          text: cleanText,
          author: 'AI Motivasyon',
          source: 'ai'
        };
      }

      return null;
    } catch (err) {
      console.warn('[QuoteService] Hugging Face API genel hata (fallback devreye giriyor):', (err as Error)?.message || err);
      return null;
    }
  }

  /**
   * Günün söz havuzunu döndürür.
   * quotes_cache.json içinde o günün sözleri varsa oradan döner;
   * yoksa Hugging Face API'den çekmeyi dener, başarılı olursa havuzun başına ekler;
   * API hata verirse veya erişilemezse fallback_quotes.json'dan yükleyip cache'e yazar ve döner.
   */
  public async getDailyQuotesPool(dateStr: string): Promise<Quote[]> {
    const cached = await this.cacheStore.read();
    if (cached.generatedAt === dateStr && cached.quotes.length > 0) {
      return cached.quotes;
    }

    // 1. Fallback söz havuzunu yükle
    const fallbackQuotes = await this.loadFallbackQuotes();

    // 2. Hugging Face API'den günün sözünü çekmeyi dene
    const hfQuote = await this.fetchHuggingFaceQuote();

    const quotesPool = hfQuote
      ? [hfQuote, ...fallbackQuotes]
      : fallbackQuotes;

    const newCache: QuotesCache = {
      generatedAt: dateStr,
      language: 'tr',
      quotes: quotesPool
    };
    await this.cacheStore.write(newCache);
    return quotesPool;
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
