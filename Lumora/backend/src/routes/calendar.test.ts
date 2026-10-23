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
import { CalendarService } from '../services/calendarService.js';
import { createCalendarRoutes } from './calendarRoutes.js';
import { errorHandler } from '../middleware/errorHandler.js';
import { config } from '../config/index.js';

describe('Calendar API Entegrasyon Testleri (/calendar)', () => {
  const testDir = path.resolve(__dirname, '../../test_tmp_calendar_api');
  const habitsFile = path.join(testDir, 'habits.json');
  const logsFile = path.join(testDir, 'habit_logs.json');
  const settingsFile = path.join(testDir, 'user_settings.json');

  let app: express.Express;
  let habitRepo: JsonHabitRepository;
  let logRepo: JsonHabitLogRepository;
  let settingsRepo: JsonUserSettingsRepository;
  let calendarService: CalendarService;

  const testUserId = 'usr_calendar_tester';
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

    calendarService = new CalendarService({
      habitRepository: habitRepo,
      habitLogRepository: logRepo,
      settingsRepository: settingsRepo
    });

    const { calendarRouter } = createCalendarRoutes(calendarService);

    app = express();
    app.use(express.json());
    app.use('/calendar', calendarRouter);
    app.use(errorHandler);
  });

  afterEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
  });

  it('1. GET /calendar: Token olmadan 401 dönmeli', async () => {
    const res = await request(app).get('/calendar');
    expect(res.status).toBe(401);
  });

  it('2. GET /calendar?month=2026-10: Geçerli token ile aylık takvim özeti dönmeli', async () => {
    // Alışkanlık oluştur (createdAt 2026-10-01)
    const habit: Habit = {
      id: 'hbt_book_test',
      userId: testUserId,
      name: 'Kitap Okuma',
      icon: 'menu_book',
      category: 'book',
      unit: 'sayfa',
      dailyGoal: 20,
      step: 5,
      repeatDays: [1, 2, 3, 4, 5, 6, 7],
      reminderTime: null,
      archived: false,
      createdAt: '2026-10-01T00:00:00.000Z'
    };
    await habitRepo['store'].write([habit]);

    // 2026-10-10 için tamamlanmış log ekle
    await logRepo.upsert(testUserId, habit.id, '2026-10-10', 20, true);

    const res = await request(app)
      .get('/calendar?month=2026-10')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.month).toBe('2026-10');
    expect(Array.isArray(res.body.days)).toBe(true);
    expect(res.body.days.length).toBe(31);
    expect(res.body.unbrokenDays).toBeGreaterThanOrEqual(1);
    expect(typeof res.body.longestStreak).toBe('number');
    expect(Array.isArray(res.body.activeHabits)).toBe(true);
    expect(res.body.activeHabits.length).toBe(1);
    expect(res.body.activeHabits[0].name).toBe('Kitap Okuma');

    const day10 = res.body.days.find((d: any) => d.date === '2026-10-10');
    expect(day10).toBeDefined();
    expect(day10.status).toBe('completed');
  });

  it('3. GET /calendar/day/:date: Belirli bir günün detaylarını dönmeli', async () => {
    const habit: Habit = {
      id: 'hbt_water_test',
      userId: testUserId,
      name: 'Su İçme',
      icon: 'water_drop',
      category: 'water',
      unit: 'ml',
      dailyGoal: 2000,
      step: 250,
      repeatDays: [1, 2, 3, 4, 5, 6, 7],
      reminderTime: null,
      archived: false,
      createdAt: '2026-10-01T00:00:00.000Z'
    };
    await habitRepo['store'].write([habit]);

    await logRepo.upsert(testUserId, habit.id, '2026-10-12', 1500, false);

    const res = await request(app)
      .get('/calendar/day/2026-10-12')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.date).toBe('2026-10-12');
    expect(res.body.status).toBe('partial');
    expect(res.body.totalPlanned).toBe(1);
    expect(res.body.completedCount).toBe(0);
    expect(res.body.habits.length).toBe(1);
    expect(res.body.habits[0].name).toBe('Su İçme');
    expect(res.body.habits[0].currentAmount).toBe(1500);
    expect(res.body.habits[0].targetAmount).toBe(2000);
  });

  it('4. GET /calendar/day/:date: Geçersiz tarih formatında 400 dönmeli', async () => {
    const res = await request(app)
      .get('/calendar/day/invalid-date')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(400);
  });
});
