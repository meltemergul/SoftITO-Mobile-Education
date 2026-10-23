import { describe, it, expect } from 'vitest';
import { Habit } from '../domain/habit.js';
import { HabitLog } from '../domain/habitLog.js';
import { calculateStats } from './statsRules.js';

describe('İstatistik Saf Fonksiyon Testleri (statsRules)', () => {
  const habits: Habit[] = [
    {
      id: 'hbt_water',
      userId: 'usr_test',
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
    },
    {
      id: 'hbt_book',
      userId: 'usr_test',
      name: 'Kitap Okuma',
      icon: 'menu_book',
      category: 'book',
      unit: 'sayfa',
      dailyGoal: 20,
      step: 5,
      repeatDays: [1, 2, 3, 4, 5, 6, 7],
      reminderTime: '21:00',
      archived: false,
      createdAt: '2026-10-01T00:00:00.000Z'
    }
  ];

  it('1. calculateStats: Başarı oranı ve trend hesaplamasını doğru yapmalı', () => {
    const todayDateStr = '2026-10-15';
    // Cari dönem: 2026-10-09'dan 2026-10-15'e (7 gün * 2 alışkanlık = 14 planlı gün)
    // Önceki dönem: 2026-10-02'den 2026-10-08'e (7 gün * 2 alışkanlık = 14 planlı gün)
    const logs: HabitLog[] = [
      // Cari dönemde 10 tamamlanan
      { id: 'l1', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-09', amount: 2000, completed: true, updatedAt: '2026-10-09T08:30:00.000Z' },
      { id: 'l2', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-10', amount: 2000, completed: true, updatedAt: '2026-10-10T08:30:00.000Z' },
      { id: 'l3', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-11', amount: 2000, completed: true, updatedAt: '2026-10-11T08:30:00.000Z' },
      { id: 'l4', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-12', amount: 2000, completed: true, updatedAt: '2026-10-12T08:30:00.000Z' },
      { id: 'l5', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-13', amount: 2000, completed: true, updatedAt: '2026-10-13T08:30:00.000Z' },
      { id: 'l6', userId: 'usr_test', habitId: 'hbt_book', date: '2026-10-09', amount: 20, completed: true, updatedAt: '2026-10-09T18:00:00.000Z' },
      { id: 'l7', userId: 'usr_test', habitId: 'hbt_book', date: '2026-10-10', amount: 20, completed: true, updatedAt: '2026-10-10T18:00:00.000Z' },

      // Önceki dönemde 7 tamamlanan (7/14 = %50)
      { id: 'l8', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-02', amount: 2000, completed: true, updatedAt: '2026-10-02T08:30:00.000Z' },
      { id: 'l9', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-03', amount: 2000, completed: true, updatedAt: '2026-10-03T08:30:00.000Z' },
      { id: 'l10', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-04', amount: 2000, completed: true, updatedAt: '2026-10-04T08:30:00.000Z' },
      { id: 'l11', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-05', amount: 2000, completed: true, updatedAt: '2026-10-05T08:30:00.000Z' },
      { id: 'l12', userId: 'usr_test', habitId: 'hbt_book', date: '2026-10-02', amount: 20, completed: true, updatedAt: '2026-10-02T21:00:00.000Z' },
      { id: 'l13', userId: 'usr_test', habitId: 'hbt_book', date: '2026-10-03', amount: 20, completed: true, updatedAt: '2026-10-03T21:00:00.000Z' },
      { id: 'l14', userId: 'usr_test', habitId: 'hbt_book', date: '2026-10-04', amount: 20, completed: true, updatedAt: '2026-10-04T21:00:00.000Z' },
    ];

    const result = calculateStats({
      range: 'weekly',
      habits,
      logs,
      todayDateStr
    });

    expect(result.range).toBe('weekly');
    expect(result.hasEnoughData).toBe(true);
    // Cari: 7/14 = %50
    expect(result.overallScore).toBe(50);
    // Önceki: 7/14 = %50 -> Trend = 50 - 50 = 0
    expect(result.trend).toBe(0);

    // Günlük grafik
    expect(result.dailyChart.length).toBe(7);
    const peakDay = result.dailyChart.find((d) => d.isPeak);
    expect(peakDay).toBeDefined();

    // Kategori dağılımı
    expect(result.categoryDistribution.length).toBe(2);

    // En verimli saatler
    expect(result.productiveHours.length).toBeGreaterThan(0);
    // 08:30 sabah ve 21:00 akşam logları var
    const morning = result.productiveHours.find((h) => h.period === 'morning');
    const evening = result.productiveHours.find((h) => h.period === 'evening');
    expect(morning).toBeDefined();
    expect(evening).toBeDefined();
  });

  it('2. En düzenli alışkanlık kuralı: Yüksek oran kazanır, eşitlikte daha uzun seri kazanır', () => {
    const todayDateStr = '2026-10-15';
    // Su ve Kitap aynı orana sahip olsun ama Su'yun serisi daha uzun olsun
    const logs: HabitLog[] = [
      { id: 'l1', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-14', amount: 2000, completed: true, updatedAt: '' },
      { id: 'l2', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-15', amount: 2000, completed: true, updatedAt: '' },
      { id: 'l3', userId: 'usr_test', habitId: 'hbt_book', date: '2026-10-15', amount: 20, completed: true, updatedAt: '' },
    ];

    const result = calculateStats({
      range: 'weekly',
      habits,
      logs,
      todayDateStr
    });

    // Su %29 (2/7), Kitap %14 (1/7) -> Su kazanır
    expect(result.bestHabit?.id).toBe('hbt_water');
  });

  it('3. Hiç veri olmadığında hasEnoughData: false dönmeli', () => {
    const result = calculateStats({
      range: 'weekly',
      habits: [],
      logs: [],
      todayDateStr: '2026-10-15'
    });

    expect(result.hasEnoughData).toBe(false);
    expect(result.overallScore).toBe(0);
    expect(result.bestHabit).toBeNull();
  });
});
