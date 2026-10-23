import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import express from 'express';
import request from 'supertest';
import path from 'node:path';
import fs from 'node:fs';
import jwt from 'jsonwebtoken';
import { JsonStore } from '../storage/jsonStore.js';
import { QuotesCache, quotesCacheSchema } from '../domain/quote.js';
import { JsonFavoriteRepository } from '../repositories/favoriteRepository.js';
import { QuoteService } from '../services/quoteService.js';
import { createQuoteRoutes } from './quoteRoutes.js';
import { errorHandler } from '../middleware/errorHandler.js';
import { config } from '../config/index.js';

describe('Quotes API Entegrasyon Testleri (/quotes)', () => {
  const testDir = path.resolve(__dirname, '../../test_tmp_quotes_api');
  const cacheFile = path.join(testDir, 'quotes_cache.json');
  const favoritesFile = path.join(testDir, 'favorites.json');
  const seedFile = path.resolve(__dirname, '../../seed/fallback_quotes.json');

  let app: express.Express;
  let quoteService: QuoteService;

  const testUserId = 'usr_quote_tester';
  const token = jwt.sign({ userId: testUserId }, config.JWT_SECRET, { expiresIn: '1h' });

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

    const favoriteRepo = new JsonFavoriteRepository(favoritesFile);

    quoteService = new QuoteService({
      cacheStoreOrPath: cacheStore,
      fallbackQuotesPath: seedFile,
      favoriteRepository: favoriteRepo
    });

    const { quoteRouter } = createQuoteRoutes(quoteService);

    app = express();
    app.use(express.json());
    app.use('/quotes', quoteRouter);
    app.use(errorHandler);
  });

  afterEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
  });

  it('1. GET /quotes/daily: Token olmadan 401 döndürmeli', async () => {
    const res = await request(app).get('/quotes/daily');
    expect(res.status).toBe(401);
  });

  it('2. GET /quotes/daily: Geçerli token ile günün sözünü döndürmeli', async () => {
    const res = await request(app)
      .get('/quotes/daily?date=2026-10-22')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.quote).toBeDefined();
    expect(res.body.quote.id).toBeDefined();
    expect(typeof res.body.quote.text).toBe('string');
    expect(res.body.quote.text.length).toBeGreaterThan(0);
    expect(res.body.quote.source).toBe('fallback');
    expect(res.body.quote.isFavorite).toBe(false);
  });

  it('3. POST /quotes/:id/favorite: Sözü favorilere eklemeli', async () => {
    // Önce günün sözünü al
    const dailyRes = await request(app)
      .get('/quotes/daily?date=2026-10-22')
      .set('Authorization', `Bearer ${token}`);
    const quoteId = dailyRes.body.quote.id;

    // Favorile
    const favRes = await request(app)
      .post(`/quotes/${quoteId}/favorite`)
      .set('Authorization', `Bearer ${token}`);

    expect(favRes.status).toBe(200);
    expect(favRes.body.success).toBe(true);
    expect(favRes.body.isFavorite).toBe(true);

    // Tekrar daily çağrıldığında isFavorite: true dönmeli
    const dailyAgain = await request(app)
      .get('/quotes/daily?date=2026-10-22')
      .set('Authorization', `Bearer ${token}`);

    expect(dailyAgain.body.quote.isFavorite).toBe(true);
  });

  it('4. DELETE /quotes/:id/favorite: Sözü favorilerden çıkarmalı', async () => {
    const dailyRes = await request(app)
      .get('/quotes/daily?date=2026-10-22')
      .set('Authorization', `Bearer ${token}`);
    const quoteId = dailyRes.body.quote.id;

    // Favoriye ekle
    await request(app)
      .post(`/quotes/${quoteId}/favorite`)
      .set('Authorization', `Bearer ${token}`);

    // Favoriden çıkar
    const delRes = await request(app)
      .delete(`/quotes/${quoteId}/favorite`)
      .set('Authorization', `Bearer ${token}`);

    expect(delRes.status).toBe(200);
    expect(delRes.body.success).toBe(true);
    expect(delRes.body.isFavorite).toBe(false);

    // Tekrar kontrol et
    const dailyAfterDel = await request(app)
      .get('/quotes/daily?date=2026-10-22')
      .set('Authorization', `Bearer ${token}`);

    expect(dailyAfterDel.body.quote.isFavorite).toBe(false);
  });
});
