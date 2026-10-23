import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import express from 'express';
import request from 'supertest';
import path from 'node:path';
import fs from 'node:fs';
import jwt from 'jsonwebtoken';
import { JsonStore } from '../storage/jsonStore.js';
import { Habit, habitsArraySchema } from '../domain/habit.js';
import { HabitLog, habitLogsArraySchema } from '../domain/habitLog.js';
import { JsonHabitRepository } from '../repositories/habitRepository.js';
import { JsonHabitLogRepository } from '../repositories/habitLogRepository.js';
import { BadgeService } from '../services/badgeService.js';
import { createBadgeRoutes } from './badgeRoutes.js';
import { errorHandler } from '../middleware/errorHandler.js';
import { config } from '../config/index.js';

describe('Badges and Level API Entegrasyon Testleri (/badges & /level)', () => {
  const testDir = path.resolve(__dirname, '../../test_tmp_badges_api');
  const habitsFile = path.join(testDir, 'habits.json');
  const logsFile = path.join(testDir, 'habit_logs.json');

  let app: express.Express;
  let habitRepo: JsonHabitRepository;
  let logRepo: JsonHabitLogRepository;
  let badgeService: BadgeService;

  const testUserId = 'usr_badge_tester';
  const token = jwt.sign({ userId: testUserId }, config.JWT_SECRET, { expiresIn: '1h' });

  beforeEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
    await fs.promises.mkdir(testDir, { recursive: true });

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

    habitRepo = new JsonHabitRepository(habitStore);
    logRepo = new JsonHabitLogRepository(logStore);

    badgeService = new BadgeService({
      habitRepository: habitRepo,
      habitLogRepository: logRepo
    });

    const { badgeRouter, levelRouter } = createBadgeRoutes(badgeService);

    app = express();
    app.use(express.json());
    app.use('/badges', badgeRouter);
    app.use('/level', levelRouter);
    app.use(errorHandler);
  });

  afterEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
  });

  it('1. Yetkilendirme (Auth Guard) kontrolü: Token yoksa 401 dönmeli', async () => {
    const resBadges = await request(app).get('/badges');
    expect(resBadges.status).toBe(401);
    expect(resBadges.body.error.code).toBe('UNAUTHORIZED');

    const resLevel = await request(app).get('/level');
    expect(resLevel.status).toBe(401);
    expect(resLevel.body.error.code).toBe('UNAUTHORIZED');
  });

  it('2. GET /badges: Kullanıcı için rozet listesini ve ilerlemeyi dönmeli', async () => {
    // Alışkanlık oluştur
    await habitRepo.create(testUserId, {
      name: 'Su İç',
      icon: 'water_drop',
      category: 'water',
      dailyGoal: 2000,
      repeatDays: [1, 2, 3, 4, 5, 6, 7]
    });
    const habits = await habitRepo.listByUser(testUserId);
    const habitId = habits[0].id;

    // 1 log tamamla
    await logRepo.upsert(testUserId, habitId, '2026-10-01', 2000, true);

    const res = await request(app)
      .get('/badges')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.totalCount).toBeGreaterThanOrEqual(7);
    expect(res.body.unlockedCount).toBe(1); // 'first_step' açıldı
    expect(res.body.newlyUnlockedBadge?.id).toBe('first_step');

    const firstStep = res.body.badges.find((b: any) => b.id === 'first_step');
    expect(firstStep.isUnlocked).toBe(true);
    expect(firstStep.unlockedAt).toBe('2026-10-01');
  });

  it('3. GET /level: Loglar ve açılan rozetlerle seviye ve XP hesaplamasını dönmeli', async () => {
    await habitRepo.create(testUserId, {
      name: 'Kitap Oku',
      icon: 'menu_book',
      category: 'book',
      dailyGoal: 20,
      repeatDays: [1, 2, 3, 4, 5, 6, 7]
    });
    const habits = await habitRepo.listByUser(testUserId);
    const habitId = habits[0].id;

    await logRepo.upsert(testUserId, habitId, '2026-10-01', 20, true);

    const res = await request(app)
      .get('/level')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    // 1 log = 15 XP + first_step rozeti = 25 XP => 40 XP
    expect(res.body.totalXp).toBe(40);
    expect(res.body.level).toBe(1);
    expect(res.body.title).toBe('Çırak');
    expect(res.body.nextLevelXp).toBe(100);
    expect(res.body.progressPercent).toBe(40);
  });
});
