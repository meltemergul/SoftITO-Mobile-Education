import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
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
import { HabitService } from '../services/habitService.js';
import { createHabitRoutes } from './habitRoutes.js';
import { errorHandler } from '../middleware/errorHandler.js';
import { config } from '../config/index.js';

describe('Habits & Logs Entegrasyon Testleri', () => {
  const testDir = path.resolve(__dirname, '../../test_tmp_habits');
  const habitsFile = path.join(testDir, 'habits.json');
  const logsFile = path.join(testDir, 'habit_logs.json');

  let app: express.Express;
  let habitRepo: JsonHabitRepository;
  let logRepo: JsonHabitLogRepository;
  let habitService: HabitService;

  const userA = { id: 'usr_test_a' };
  const userB = { id: 'usr_test_b' };

  function createToken(userId: string): string {
    return jwt.sign({ userId }, config.JWT_SECRET, { expiresIn: '1h' });
  }

  const tokenA = createToken(userA.id);
  const tokenB = createToken(userB.id);

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
    habitService = new HabitService(habitRepo, logRepo);

    const routes = createHabitRoutes(habitService);

    app = express();
    app.use(express.json());
    app.use('/habits', routes.habitRouter);
    app.use('/logs', routes.logRouter);
    app.use('/habit-templates', routes.templateRouter);
    app.use(errorHandler);
  });

  afterEach(async () => {
    vi.restoreAllMocks();
    await fs.promises.rm(testDir, { recursive: true, force: true });
  });

  it('1. GET /habit-templates: Sabit şablon listesi dönmeli', async () => {
    const res = await request(app)
      .get('/habit-templates')
      .set('Authorization', `Bearer ${tokenA}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThanOrEqual(5);

    const water = res.body.find((t: any) => t.category === 'water');
    expect(water).toBeDefined();
    expect(water.name).toBe('Su İçme');
    expect(water.dailyGoal).toBe(2500);
    expect(water.unit).toBe('ml');
  });

  it('2. POST /habits: Başarılı alışkanlık oluşturma', async () => {
    const res = await request(app)
      .post('/habits')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'Günde 2 Litre Su',
        icon: 'water_drop',
        category: 'water',
        unit: 'ml',
        dailyGoal: 2000,
        step: 250,
        repeatDays: [1, 2, 3, 4, 5, 6, 7],
        reminderTime: '09:30'
      });

    expect(res.status).toBe(201);
    expect(res.body.id).toMatch(/^hbt_/);
    expect(res.body.userId).toBe(userA.id);
    expect(res.body.name).toBe('Günde 2 Litre Su');
    expect(res.body.dailyGoal).toBe(2000);
    expect(res.body.archived).toBe(false);
  });

  it('3. Girdi doğrulaması (zod): repeatDays, reminderTime ve dailyGoal kuralları', async () => {
    // 3a: repeatDays 1-7 dışı değer (ör. 8 veya 0)
    const resInvalidDays = await request(app)
      .post('/habits')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'Hatalı Günler',
        icon: 'star',
        category: 'custom',
        dailyGoal: 10,
        repeatDays: [1, 8] // 8 geçersiz
      });
    expect(resInvalidDays.status).toBe(400);
    expect(resInvalidDays.body.error.code).toBe('VALIDATION_ERROR');

    // 3b: Boş repeatDays
    const resEmptyDays = await request(app)
      .post('/habits')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'Boş Günler',
        icon: 'star',
        category: 'custom',
        dailyGoal: 10,
        repeatDays: []
      });
    expect(resEmptyDays.status).toBe(400);

    // 3c: reminderTime geçersiz saat formatı (ör. "25:99")
    const resInvalidTime = await request(app)
      .post('/habits')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'Hatalı Saat',
        icon: 'alarm',
        category: 'mind',
        dailyGoal: 1,
        repeatDays: [1, 2],
        reminderTime: '25:99'
      });
    expect(resInvalidTime.status).toBe(400);

    // 3d: dailyGoal <= 0
    const resInvalidGoal = await request(app)
      .post('/habits')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'Sıfır Hedef',
        icon: 'check',
        category: 'custom',
        dailyGoal: 0,
        repeatDays: [1]
      });
    expect(resInvalidGoal.status).toBe(400);
  });

  it('4. Başka kullanıcının alışkanlığına erişimin reddedilmesi (404 Not Found)', async () => {
    // User A bir alışkanlık oluşturur
    const createRes = await request(app)
      .post('/habits')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'User A Alışkanlığı',
        icon: 'book',
        category: 'book',
        dailyGoal: 30,
        repeatDays: [1, 2, 3, 4, 5]
      });
    const habitId = createRes.body.id;

    // User B bu alışkanlığı okumaya çalışır
    const getRes = await request(app)
      .get(`/habits/${habitId}`)
      .set('Authorization', `Bearer ${tokenB}`);
    expect(getRes.status).toBe(404);
    expect(getRes.body.error.code).toBe('NOT_FOUND');

    // User B bu alışkanlığı güncellemeye çalışır
    const patchRes = await request(app)
      .patch(`/habits/${habitId}`)
      .set('Authorization', `Bearer ${tokenB}`)
      .send({ name: 'Hacklendi' });
    expect(patchRes.status).toBe(404);

    // User B bu alışkanlığı silmeye/arşivlemeye çalışır
    const deleteRes = await request(app)
      .delete(`/habits/${habitId}`)
      .set('Authorization', `Bearer ${tokenB}`);
    expect(deleteRes.status).toBe(404);

    // User B bu alışkanlığa log girmeye çalışır
    const logRes = await request(app)
      .put(`/habits/${habitId}/logs/2026-10-22`)
      .set('Authorization', `Bearer ${tokenB}`)
      .send({ amount: 10 });
    expect(logRes.status).toBe(404);
  });

  it('5. Arşivlenen alışkanlığın loglarının korunması', async () => {
    // Alışkanlık oluştur
    const habitRes = await request(app)
      .post('/habits')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'Eski Alışkanlık',
        icon: 'menu_book',
        category: 'book',
        dailyGoal: 20,
        repeatDays: [1, 2, 3]
      });
    const habitId = habitRes.body.id;

    // Log ekle
    const logRes = await request(app)
      .put(`/habits/${habitId}/logs/2026-10-20`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ amount: 20 });
    expect(logRes.status).toBe(200);
    expect(logRes.body.completed).toBe(true);

    // Alışkanlığı sil (arşivle)
    const delRes = await request(app)
      .delete(`/habits/${habitId}`)
      .set('Authorization', `Bearer ${tokenA}`);
    expect(delRes.status).toBe(200);
    expect(delRes.body.archived).toBe(true);

    // Alışkanlık varsayılan /habits listesinde gelmemeli
    const listRes = await request(app)
      .get('/habits')
      .set('Authorization', `Bearer ${tokenA}`);
    expect(listRes.body.some((h: any) => h.id === habitId)).toBe(false);

    // Ancak geçmiş loglar GET /logs ile hala korunmalı ve erişilebilir olmalı
    const logsRes = await request(app)
      .get('/logs')
      .set('Authorization', `Bearer ${tokenA}`);
    expect(logsRes.status).toBe(200);
    const savedLog = logsRes.body.find((l: any) => l.habitId === habitId);
    expect(savedLog).toBeDefined();
    expect(savedLog.amount).toBe(20);
    expect(savedLog.completed).toBe(true);
  });

  it('6. Delta ile artırma/azaltma ve tamamlanma sınırı kontrolü', async () => {
    // Hedef 2000 ml olan bir su alışkanlığı
    const habitRes = await request(app)
      .post('/habits')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'Su Takibi',
        icon: 'water_drop',
        category: 'water',
        unit: 'ml',
        dailyGoal: 2000,
        step: 250,
        repeatDays: [1, 2, 3, 4, 5, 6, 7]
      });
    const habitId = habitRes.body.id;
    const testDate = '2026-10-22';

    // 1. Adım: İlk kayıt amount ile 1000 ml girildi
    const step1 = await request(app)
      .put(`/habits/${habitId}/logs/${testDate}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ amount: 1000 });
    expect(step1.status).toBe(200);
    expect(step1.body.amount).toBe(1000);
    expect(step1.body.completed).toBe(false); // 1000 < 2000

    // 2. Adım: Delta ile 1000 ml artırıldı -> toplam 2000 ml oldu (tamamlanma sınırı: true)
    const step2 = await request(app)
      .put(`/habits/${habitId}/logs/${testDate}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ delta: 1000 });
    expect(step2.status).toBe(200);
    expect(step2.body.amount).toBe(2000);
    expect(step2.body.completed).toBe(true); // 2000 >= 2000 -> otomatik true
    expect(step2.body.id).toBe(step1.body.id); // Aynı gün tek kayıt (aynı id)

    // 3. Adım: Delta ile 500 ml azaltıldı -> toplam 1500 ml oldu (tamamlanma sınırı: false'a geri döner)
    const step3 = await request(app)
      .put(`/habits/${habitId}/logs/${testDate}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ delta: -500 });
    expect(step3.status).toBe(200);
    expect(step3.body.amount).toBe(1500);
    expect(step3.body.completed).toBe(false); // 1500 < 2000 -> otomatik false

    // 4. Adım: Aşırı azaltma yapıldığında amount 0'ın altına inmemeli
    const step4 = await request(app)
      .put(`/habits/${habitId}/logs/${testDate}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ delta: -3000 });
    expect(step4.status).toBe(200);
    expect(step4.body.amount).toBe(0); // 1500 - 3000 = -1500 -> 0'a sabitlenir
    expect(step4.body.completed).toBe(false);
  });

  it('7. GET /logs?from=&to=: Tarih aralığı filtresi', async () => {
    const habitRes = await request(app)
      .post('/habits')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'Koşu',
        icon: 'directions_run',
        category: 'sport',
        dailyGoal: 5,
        repeatDays: [1, 2, 3, 4, 5, 6, 7]
      });
    const habitId = habitRes.body.id;

    // Farklı tarihlerde loglar ekle
    await request(app)
      .put(`/habits/${habitId}/logs/2026-10-01`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ amount: 5 });
    await request(app)
      .put(`/habits/${habitId}/logs/2026-10-15`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ amount: 5 });
    await request(app)
      .put(`/habits/${habitId}/logs/2026-10-31`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ amount: 5 });

    // from & to filtresi (10 ile 20 arası)
    const resFiltered = await request(app)
      .get('/logs?from=2026-10-10&to=2026-10-20')
      .set('Authorization', `Bearer ${tokenA}`);

    expect(resFiltered.status).toBe(200);
    expect(resFiltered.body.length).toBe(1);
    expect(resFiltered.body[0].date).toBe('2026-10-15');
  });
});
