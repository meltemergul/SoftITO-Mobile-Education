import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import path from 'node:path';
import fs from 'node:fs';
import { QuoteService, getDeterministicIndex } from './quoteService.js';
import { JsonStore } from '../storage/jsonStore.js';
import { QuotesCache, quotesCacheSchema } from '../domain/quote.js';
import { JsonFavoriteRepository } from '../repositories/favoriteRepository.js';

describe('QuoteService Birim Testleri', () => {
  const testDir = path.resolve(__dirname, '../../test_tmp_quote_service');
  const cacheFile = path.join(testDir, 'quotes_cache.json');
  const favoritesFile = path.join(testDir, 'favorites.json');
  const seedFile = path.resolve(__dirname, '../../seed/fallback_quotes.json');

  let service: QuoteService;
  let favoriteRepo: JsonFavoriteRepository;

  beforeEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
    await fs.promises.mkdir(testDir, { recursive: true });

    const cacheStore = new JsonStore<QuotesCache>({
      filePath: cacheFile,
      schema: quotesCacheSchema,
      defaultValue: {
        generatedAt: '',
        language: 'tr',
        quotes: []
      }
    });

    favoriteRepo = new JsonFavoriteRepository(favoritesFile);

    service = new QuoteService({
      cacheStoreOrPath: cacheStore,
      fallbackQuotesPath: seedFile,
      favoriteRepository: favoriteRepo
    });
  });

  afterEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
  });

  it('1. fallback_quotes.json tam 40 Türkçe söz içermeli ve şemaya uygun olmalı', async () => {
    const fallbackQuotes = await service.loadFallbackQuotes();
    expect(fallbackQuotes.length).toBe(40);

    for (const q of fallbackQuotes) {
      expect(q.id).toBeDefined();
      expect(q.text.length).toBeGreaterThan(10);
      expect(q.source).toBe('fallback');
      // Atıf varsa boş string olmamalı, yoksa null olmalı
      if (q.author !== null) {
        expect(typeof q.author).toBe('string');
        expect(q.author.length).toBeGreaterThan(0);
      }
    }
  });

  it('2. Deterministik seçim: Aynı tarih ve aynı userId her zaman aynı sözü almalı', async () => {
    const userId1 = 'usr_alice';
    const dateStr = '2026-10-22';

    const quoteCall1 = await service.getDailyQuote(userId1, dateStr);
    const quoteCall2 = await service.getDailyQuote(userId1, dateStr);

    expect(quoteCall1.id).toBe(quoteCall2.id);
    expect(quoteCall1.text).toBe(quoteCall2.text);
    expect(quoteCall1.author).toBe(quoteCall2.author);
  });

  it('3. Deterministik hash fonksiyonu beklenen aralıkta tamsayı üretmeli', () => {
    const idx1 = getDeterministicIndex('2026-10-22:usr_1', 40);
    const idx2 = getDeterministicIndex('2026-10-22:usr_1', 40);
    const idx3 = getDeterministicIndex('2026-10-23:usr_1', 40);

    expect(idx1).toBe(idx2);
    expect(idx1).toBeGreaterThanOrEqual(0);
    expect(idx1).toBeLessThan(40);
    expect(idx3).toBeGreaterThanOrEqual(0);
    expect(idx3).toBeLessThan(40);
  });

  it('4. quotes_cache.json ilk çağrıda oluşturulmalı ve sonraki çağrılarda kullanılmalı', async () => {
    const dateStr = '2026-10-22';
    expect(fs.existsSync(cacheFile)).toBe(false);

    await service.getDailyQuote('usr_test', dateStr);

    expect(fs.existsSync(cacheFile)).toBe(true);
    const cacheContent = JSON.parse(await fs.promises.readFile(cacheFile, 'utf-8'));
    expect(cacheContent.generatedAt).toBe(dateStr);
    expect(cacheContent.quotes.length).toBe(40);
  });

  it('5. Favorileme: addFavorite ve removeFavorite isFavorite durumunu doğru yansıtmalı', async () => {
    const userId = 'usr_fav_tester';
    const dateStr = '2026-10-22';

    const initialQuote = await service.getDailyQuote(userId, dateStr);
    expect(initialQuote.isFavorite).toBe(false);

    await service.addFavorite(userId, initialQuote.id);
    const afterAdd = await service.getDailyQuote(userId, dateStr);
    expect(afterAdd.isFavorite).toBe(true);

    await service.removeFavorite(userId, initialQuote.id);
    const afterRemove = await service.getDailyQuote(userId, dateStr);
    expect(afterRemove.isFavorite).toBe(false);
  });
});
