import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
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
import { TodayService } from '../services/todayService.js';
import { createTodayRouter } from './todayRoutes.js';
import { errorHandler } from '../middleware/errorHandler.js';
import { config } from '../config/index.js';
import { formatDateInTimezone } from '../services/domainRules.js';

describe('GET /today Entegrasyon Testleri', () => {
  const testDir = path.resolve(__dirname, '../../test_tmp_today');
  const habitsFile = path.join(testDir, 'habits.json');
  const logsFile = path.join(testDir, 'habit_logs.json');
  const settingsFile = path.join(testDir, 'user_settings.json');

  let app: express.Express;
  let habitRepo: JsonHabitRepository;
  let logRepo: JsonHabitLogRepository;
  let settingsRepo: JsonUserSettingsRepository;
  let todayService: TodayService;

  const testUserId = 'usr_today_tester';
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
    todayService = new TodayService(habitRepo, logRepo, settingsRepo);

    app = express();
    app.use(express.json());
    app.use('/today', createTodayRouter(todayService));
    app.use(errorHandler);
  });

  afterEach(async () => {
    vi.restoreAllMocks();
    await fs.promises.rm(testDir, { recursive: true, force: true });
  });

  it('1. GET /today: Başarılı veri dönüşü (planlı alışkanlıklar, ilerleme, XP, streak)', async () => {
    const todayStr = formatDateInTimezone(new Date(), 'Europe/Istanbul');

    // 1. Alışkanlık oluştur
    const habit = await habitRepo.create(testUserId, {
      name: 'Günlük Su',
      icon: 'water_drop',
      category: 'water',
      unit: 'ml',
      dailyGoal: 2000,
      step: 250,
      repeatDays: [1, 2, 3, 4, 5, 6, 7]
    });

    // 2. Bugün için log ekle (tamamlanmış: 2000 ml)
    await logRepo.upsert(testUserId, habit.id, todayStr, 2000, true);

    const res = await request(app)
      .get('/today')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.date).toBe(todayStr);
    expect(res.body.timezone).toBe('Europe/Istanbul');
    expect(res.body.progress.total).toBe(1);
    expect(res.body.progress.completed).toBe(1);
    expect(res.body.progress.percentage).toBe(100);
    expect(res.body.progress.isAllCompleted).toBe(true);

    expect(res.body.xp.totalXp).toBe(15);
    expect(res.body.xp.level).toBe(1);

    expect(res.body.habits.length).toBe(1);
    expect(res.body.habits[0].name).toBe('Günlük Su');
    expect(res.body.habits[0].isPlannedToday).toBe(true);
    expect(res.body.habits[0].isCompletedToday).toBe(true);
    expect(res.body.habits[0].currentAmount).toBe(2000);
    expect(res.body.habits[0].currentStreak).toBe(1);
  });
});
