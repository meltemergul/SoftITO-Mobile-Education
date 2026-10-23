import { describe, it, expect } from 'vitest';
import { Habit } from '../domain/habit.js';
import { HabitLog } from '../domain/habitLog.js';
import { calculateMonthCalendar, calculateDayDetail } from './calendarRules.js';

describe('Takvim Saf Fonksiyon Testleri (calendarRules)', () => {
  const mockHabits: Habit[] = [
    {
      id: 'hbt_water',
      userId: 'usr_test',
      name: 'Su İçme',
      icon: 'water_drop',
      category: 'water',
      unit: 'ml',
      dailyGoal: 2000,
      step: 250,
      repeatDays: [1, 2, 3, 4, 5, 6, 7], // Her gün
      reminderTime: '10:00',
      archived: false,
      createdAt: '2026-10-01T00:00:00.000Z'
    },
    {
      id: 'hbt_run',
      userId: 'usr_test',
      name: 'Sabah Koşusu',
      icon: 'directions_run',
      category: 'sport',
      unit: 'km',
      dailyGoal: 5,
      step: 1,
      repeatDays: [1, 3, 5], // Pzt, Çar, Cuma
      reminderTime: '07:30',
      archived: false,
      createdAt: '2026-10-01T00:00:00.000Z'
    }
  ];

  it('1. calculateMonthCalendar: Ayın tüm günlerini doğru durumlarla hesaplamalı', () => {
    const todayDateStr = '2026-10-15';
    const logs: HabitLog[] = [
      // 2026-10-01 (Perşembe: sadece su planlı) -> Su tamamlandı -> 'completed'
      { id: 'l1', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-01', amount: 2000, completed: true, updatedAt: '' },
      // 2026-10-02 (Cuma: su ve koşu planlı) -> Sadece su tamamlandı -> 'partial'
      { id: 'l2', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-02', amount: 2000, completed: true, updatedAt: '' },
      // 2026-10-03 (Cumartesi: sadece su planlı) -> Hiç log yok -> 'empty'
    ];

    const result = calculateMonthCalendar({
      month: '2026-10',
      habits: mockHabits,
      logs,
      todayDateStr,
      streakFreezeCount: 2
    });

    expect(result.month).toBe('2026-10');
    expect(result.days.length).toBe(31); // Ekim ayı 31 gün

    // 1 Ekim
    const day1 = result.days.find((d) => d.date === '2026-10-01');
    expect(day1?.status).toBe('completed');
    expect(day1?.totalPlanned).toBe(1);
    expect(day1?.completedCount).toBe(1);

    // 2 Ekim
    const day2 = result.days.find((d) => d.date === '2026-10-02');
    expect(day2?.status).toBe('partial');
    expect(day2?.totalPlanned).toBe(2);
    expect(day2?.completedCount).toBe(1);

    // 3 Ekim
    const day3 = result.days.find((d) => d.date === '2026-10-03');
    expect(day3?.status).toBe('empty');

    // 16 Ekim (Gelecek)
    const day16 = result.days.find((d) => d.date === '2026-10-16');
    expect(day16?.status).toBe('future');

    // Bugün kontrolü
    const today = result.days.find((d) => d.date === todayDateStr);
    expect(today?.isToday).toBe(true);

    // unbrokenDays
    expect(result.unbrokenDays).toBe(1);

    // activeHabits
    expect(result.activeHabits.length).toBe(2);
    expect(result.activeHabits[0].last7Days.length).toBe(7);
  });

  it('2. calculateDayDetail: Belirli bir gün için tüm alışkanlık detaylarını dönmeli', () => {
    const todayDateStr = '2026-10-15';
    const logs: HabitLog[] = [
      { id: 'l1', userId: 'usr_test', habitId: 'hbt_water', date: '2026-10-02', amount: 1500, completed: false, updatedAt: '' }
    ];

    const detail = calculateDayDetail({
      dateStr: '2026-10-02',
      habits: mockHabits,
      logs,
      todayDateStr
    });

    expect(detail.date).toBe('2026-10-02');
    expect(detail.status).toBe('partial');
    expect(detail.totalPlanned).toBe(2);
    expect(detail.completedCount).toBe(0);
    expect(detail.habits.length).toBe(2);

    const waterDetail = detail.habits.find((h) => h.id === 'hbt_water');
    expect(waterDetail?.isPlanned).toBe(true);
    expect(waterDetail?.currentAmount).toBe(1500);
    expect(waterDetail?.targetAmount).toBe(2000);
    expect(waterDetail?.isCompleted).toBe(false);
  });
});
