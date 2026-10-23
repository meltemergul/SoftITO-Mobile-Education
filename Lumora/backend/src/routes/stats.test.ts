import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import express from 'express';
import request from 'supertest';
import path from 'node:path';
import fs from 'node:fs';
import jwt from 'jsonwebtoken';
import { JsonStore } from '../storage/jsonStore.js';
import { Habit, habitsArraySchema } from '../domain/habit.js';
import { HabitLog, habitLogsArraySchema } from '../domain/habitLog.js';
import { UserSettings, userSettingsArraySchema } from '../domain/settings.js';
import { JsonHabitRepository } from '../repositories/habitRepository.js';
import { JsonHabitLogRepository } from '../repositories/habitLogRepository.js';
import { JsonUserSettingsRepository } from '../repositories/settingsRepository.js';
import { StatsService } from '../services/statsService.js';
import { createStatsRoutes } from './statsRoutes.js';
import { errorHandler } from '../middleware/errorHandler.js';
import { config } from '../config/index.js';

describe('Stats API Entegrasyon Testleri (/stats)', () => {
  const testDir = path.resolve(__dirname, '../../test_tmp_stats_api');
  const habitsFile = path.join(testDir, 'habits.json');
  const logsFile = path.join(testDir, 'habit_logs.json');
  const settingsFile = path.join(testDir, 'user_settings.json');

  let app: express.Express;
  let habitRepo: JsonHabitRepository;
  let logRepo: JsonHabitLogRepository;
  let settingsRepo: JsonUserSettingsRepository;
  let statsService: StatsService;

  const testUserId = 'usr_stats_tester';
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

    const settingsStore = new JsonStore<UserSettings[]>({
      filePath: settingsFile,
      schema: userSettingsArraySchema,
      defaultValue: []
    });

    habitRepo = new JsonHabitRepository(habitStore);
    logRepo = new JsonHabitLogRepository(logStore);
    settingsRepo = new JsonUserSettingsRepository(settingsStore);

    statsService = new StatsService({
      habitRepository: habitRepo,
      habitLogRepository: logRepo,
      settingsRepository: settingsRepo
    });

    const { statsRouter } = createStatsRoutes(statsService);

    app = express();
    app.use(express.json());
    app.use('/stats', statsRouter);
    app.use(errorHandler);
  });

  afterEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
  });

  it('1. GET /stats: Token olmadan 401 dönmeli', async () => {
    const res = await request(app).get('/stats');
    expect(res.status).toBe(401);
  });

  it('2. GET /stats?range=weekly: İstatistik özetini başarıyla dönmeli', async () => {
    const habit: Habit = {
      id: 'hbt_water_stats',
      userId: testUserId,
      name: 'Su İçme',
      icon: 'water_drop',
      category: 'water',
      unit: 'ml',
      dailyGoal: 2000,
      step: 250,
      repeatDays: [1, 2, 3, 4, 5, 6, 7],
      reminderTime: '10:00',
      archived: false,
      createdAt: '2026-10-01T00:00:00.000Z'
    };
    await habitRepo['store'].write([habit]);

    // Bugün için tamamlanmış log ekle
    const todayStr = new Date().toISOString().slice(0, 10);
    await logRepo.upsert(testUserId, habit.id, todayStr, 2000, true);

    const res = await request(app)
      .get('/stats?range=weekly')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.range).toBe('weekly');
    expect(res.body.hasEnoughData).toBe(true);
    expect(typeof res.body.overallScore).toBe('number');
    expect(Array.isArray(res.body.dailyChart)).toBe(true);
    expect(Array.isArray(res.body.categoryDistribution)).toBe(true);
    expect(Array.isArray(res.body.productiveHours)).toBe(true);
    expect(Array.isArray(res.body.habitProgress)).toBe(true);
    expect(res.body.bestHabit).toBeDefined();
    expect(res.body.bestHabit?.name).toBe('Su İçme');
  });

  it('3. GET /stats?range=monthly ve range=all desteklenmeli', async () => {
    const resMonthly = await request(app)
      .get('/stats?range=monthly')
      .set('Authorization', `Bearer ${token}`);
    expect(resMonthly.status).toBe(200);
    expect(resMonthly.body.range).toBe('monthly');

    const resAll = await request(app)
      .get('/stats?range=all')
      .set('Authorization', `Bearer ${token}`);
    expect(resAll.status).toBe(200);
    expect(resAll.body.range).toBe('all');
    expect(resAll.body.trend).toBeNull(); // 'all' için trend null olur
  });
});
