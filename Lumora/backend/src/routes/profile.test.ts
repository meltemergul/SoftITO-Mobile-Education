import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import express from 'express';
import request from 'supertest';
import path from 'node:path';
import fs from 'node:fs';
import jwt from 'jsonwebtoken';
import { JsonStore } from '../storage/jsonStore.js';
import { User, usersArraySchema } from '../domain/user.js';
import { Habit, habitsArraySchema } from '../domain/habit.js';
import { HabitLog, habitLogsArraySchema } from '../domain/habitLog.js';
import { UserSettings, userSettingsArraySchema } from '../domain/settings.js';
import { FavoriteRecord, favoriteRecordSchema } from '../domain/quote.js';
import { z } from 'zod';
import { JsonUserRepository } from '../repositories/userRepository.js';
import { JsonHabitRepository } from '../repositories/habitRepository.js';
import { JsonHabitLogRepository } from '../repositories/habitLogRepository.js';
import { JsonUserSettingsRepository } from '../repositories/settingsRepository.js';
import { JsonFavoriteRepository } from '../repositories/favoriteRepository.js';
import { ProfileService } from '../services/profileService.js';
import { createProfileRoutes } from './profileRoutes.js';
import { errorHandler } from '../middleware/errorHandler.js';
import { config } from '../config/index.js';

describe('Profile, Settings, Export & Account Deletion API Entegrasyon Testleri', () => {
  const testDir = path.resolve(__dirname, '../../test_tmp_profile_api');
  const usersFile = path.join(testDir, 'users.json');
  const habitsFile = path.join(testDir, 'habits.json');
  const logsFile = path.join(testDir, 'habit_logs.json');
  const settingsFile = path.join(testDir, 'user_settings.json');
  const favoritesFile = path.join(testDir, 'favorites.json');

  let app: express.Express;
  let userRepo: JsonUserRepository;
  let habitRepo: JsonHabitRepository;
  let logRepo: JsonHabitLogRepository;
  let settingsRepo: JsonUserSettingsRepository;
  let favoriteRepo: JsonFavoriteRepository;
  let profileService: ProfileService;

  const testUserId = 'usr_profile_tester';
  const token = jwt.sign({ userId: testUserId }, config.JWT_SECRET, { expiresIn: '1h' });

  beforeEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
    await fs.promises.mkdir(testDir, { recursive: true });

    const userStore = new JsonStore<User[]>({
      filePath: usersFile,
      schema: usersArraySchema,
      defaultValue: []
    });

    const habitStore = new JsonStore<Habit[]>({
      filePath: habitsFile,
      schema: habitsArraySchema,
      defaultValue: []
    });

    const logStore = new JsonStore<HabitLog[]>({
      filePath: logsFile,
      schema: habitLogsArraySchema,
      defaultValue: []
    });

    const settingsStore = new JsonStore<UserSettings[]>({
      filePath: settingsFile,
      schema: userSettingsArraySchema,
      defaultValue: []
    });

    const favoriteStore = new JsonStore<FavoriteRecord[]>({
      filePath: favoritesFile,
      schema: z.array(favoriteRecordSchema),
      defaultValue: []
    });

    userRepo = new JsonUserRepository(userStore);
    habitRepo = new JsonHabitRepository(habitStore);
    logRepo = new JsonHabitLogRepository(logStore);
    settingsRepo = new JsonUserSettingsRepository(settingsStore);
    favoriteRepo = new JsonFavoriteRepository(favoriteStore);

    profileService = new ProfileService({
      userRepository: userRepo,
      settingsRepository: settingsRepo,
      habitRepository: habitRepo,
      habitLogRepository: logRepo,
      favoriteRepository: favoriteRepo
    });

    const { profileRouter, settingsRouter, exportRouter, accountRouter } =
      createProfileRoutes(profileService);

    app = express();
    app.use(express.json());
    app.use('/profile', profileRouter);
    app.use('/settings', settingsRouter);
    app.use('/export', exportRouter);
    app.use('/account', accountRouter);
    app.use(errorHandler);

    // Test kullanıcısını oluştur
    await userRepo.create({
      id: testUserId,
      email: 'test@lumora.app',
      passwordHash: 'hash12345678',
      displayName: 'Selin Yılmaz',
      username: 'selin',
      avatarUrl: null,
      isGuest: false,
      createdAt: '2026-10-01T10:00:00.000Z'
    });
  });

  afterEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
  });

  it('1. Yetkilendirme Kontrolü: Token olmadan erişim 401 dönmeli', async () => {
    const resProfile = await request(app).get('/profile');
    expect(resProfile.status).toBe(401);

    const resSettings = await request(app).get('/settings');
    expect(resSettings.status).toBe(401);

    const resExport = await request(app).get('/export');
    expect(resExport.status).toBe(401);

    const resDelete = await request(app).delete('/account');
    expect(resDelete.status).toBe(401);
  });

  it('2. GET ve PATCH /profile: Profil bilgilerini ve hızlı metrikleri doğru dönmeli ve güncellemeli', async () => {
    // Alışkanlık ekle
    await habitRepo.create(testUserId, {
      name: 'Su İç',
      icon: 'water_drop',
      category: 'water',
      dailyGoal: 2000,
      repeatDays: [1, 2, 3, 4, 5, 6, 7]
    });

    const getRes = await request(app)
      .get('/profile')
      .set('Authorization', `Bearer ${token}`);

    expect(getRes.status).toBe(200);
    expect(getRes.body.user.displayName).toBe('Selin Yılmaz');
    expect(getRes.body.user.username).toBe('selin');
    expect(getRes.body.user).not.toHaveProperty('passwordHash');
    expect(getRes.body.quickMetrics.totalGoals).toBe(1);

    // Profil güncelle
    const patchRes = await request(app)
      .patch('/profile')
      .set('Authorization', `Bearer ${token}`)
      .send({
        displayName: 'Selin Demir',
        username: 'selind'
      });

    expect(patchRes.status).toBe(200);
    expect(patchRes.body.displayName).toBe('Selin Demir');
    expect(patchRes.body.username).toBe('selind');
  });

  it('3. GET ve PATCH /settings: Ayarları getirmeli ve bildirim/tema ayarlarını güncellemeli', async () => {
    const getRes = await request(app)
      .get('/settings')
      .set('Authorization', `Bearer ${token}`);

    expect(getRes.status).toBe(200);
    expect(getRes.body.theme).toBe('system');
    expect(getRes.body.notifications.morningMotivation.time).toBe('08:00');
    expect(getRes.body.notifications.eveningChainCheck.time).toBe('21:30');

    // Ayar güncelle
    const patchRes = await request(app)
      .patch('/settings')
      .set('Authorization', `Bearer ${token}`)
      .send({
        theme: 'dark',
        weekStartsOn: 7, // Pazar
        notifications: {
          smart: false,
          morningMotivation: { enabled: true, time: '07:30' }
        }
      });

    expect(patchRes.status).toBe(200);
    expect(patchRes.body.theme).toBe('dark');
    expect(patchRes.body.weekStartsOn).toBe(7);
    expect(patchRes.body.notifications.smart).toBe(false);
    expect(patchRes.body.notifications.morningMotivation.time).toBe('07:30');
    // eveningChainCheck silinmemiş olmalı (deep merge)
    expect(patchRes.body.notifications.eveningChainCheck.time).toBe('21:30');
  });

  it('4. GET /export: Verileri hem JSON hem CSV formatında doğru dışa aktarmalı', async () => {
    // Alışkanlık, log ve favori oluştur
    const habit = await habitRepo.create(testUserId, {
      name: 'Kitap Oku',
      icon: 'menu_book',
      category: 'book',
      dailyGoal: 30,
      repeatDays: [1, 2, 3, 4, 5, 6, 7]
    });

    await logRepo.upsert(testUserId, habit.id, '2026-10-15', 30, true);
    await favoriteRepo.addFavorite(testUserId, 'quote_123');

    // JSON export
    const jsonRes = await request(app)
      .get('/export?format=json')
      .set('Authorization', `Bearer ${token}`);

    expect(jsonRes.status).toBe(200);
    expect(jsonRes.headers['content-type']).toContain('application/json');
    expect(jsonRes.body.user.id).toBe(testUserId);
    expect(jsonRes.body.habits.length).toBe(1);
    expect(jsonRes.body.habits[0].name).toBe('Kitap Oku');
    expect(jsonRes.body.logs.length).toBe(1);
    expect(jsonRes.body.logs[0].amount).toBe(30);
    expect(jsonRes.body.favorites.length).toBe(1);

    // CSV export
    const csvRes = await request(app)
      .get('/export?format=csv')
      .set('Authorization', `Bearer ${token}`);

    expect(csvRes.status).toBe(200);
    expect(csvRes.headers['content-type']).toContain('text/csv');
    expect(csvRes.text).toContain('--- ALISKANLIKLAR ---');
    expect(csvRes.text).toContain('Kitap Oku');
    expect(csvRes.text).toContain('--- TAMAMLANMA KAYITLARI (LOGS) ---');
    expect(csvRes.text).toContain('2026-10-15');
  });

  it('5. DELETE /account: Kullanıcının tüm kayıtlarını (kullanıcı, alışkanlık, log, ayar, favori) kalıcı olarak silmeli', async () => {
    // Verileri doldur
    const habit = await habitRepo.create(testUserId, {
      name: 'Sabah Koşusu',
      icon: 'directions_run',
      category: 'sport',
      dailyGoal: 5,
      repeatDays: [1, 2, 3, 4, 5, 6, 7]
    });
    await logRepo.upsert(testUserId, habit.id, '2026-10-10', 5, true);
    await settingsRepo.update(testUserId, { theme: 'dark' });
    await favoriteRepo.addFavorite(testUserId, 'quote_test');

    // Ön doğrulama
    expect(await userRepo.findById(testUserId)).not.toBeNull();
    expect((await habitRepo.listByUser(testUserId, true)).length).toBe(1);
    expect((await logRepo.listByUserAndDateRange(testUserId)).length).toBe(1);
    expect((await favoriteRepo.listFavorites(testUserId)).length).toBe(1);

    // DELETE /account çağrısı
    const deleteRes = await request(app)
      .delete('/account')
      .set('Authorization', `Bearer ${token}`);

    expect(deleteRes.status).toBe(200);
    expect(deleteRes.body.success).toBe(true);

    // Kalıcı silinme kontrolleri
    expect(await userRepo.findById(testUserId)).toBeNull();
    expect((await habitRepo.listByUser(testUserId, true)).length).toBe(0);
    expect((await logRepo.listByUserAndDateRange(testUserId)).length).toBe(0);
    expect((await favoriteRepo.listFavorites(testUserId)).length).toBe(0);

    // Settings dosyasında da userId kalmamış olmalı
    const allSettings = await (settingsRepo as any).store.read();
    expect(allSettings.some((s: any) => s.userId === testUserId)).toBe(false);
  });
});
