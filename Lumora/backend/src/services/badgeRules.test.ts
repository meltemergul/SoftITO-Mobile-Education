import { describe, it, expect } from 'vitest';
import { Habit } from '../domain/habit.js';
import { HabitLog } from '../domain/habitLog.js';
import {
  evaluateBadges,
  calculateUserLevelWithBadges,
  BADGE_DEFINITIONS
} from './badgeRules.js';

describe('BadgeRules & Evaluation Unit Tests', () => {
  const dummyHabit: Habit = {
    id: 'h_water',
    userId: 'u_1',
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

  const sportHabit: Habit = {
    id: 'h_run',
    userId: 'u_1',
    name: 'Sabah Koşusu',
    icon: 'directions_run',
    category: 'sport',
    unit: 'km',
    dailyGoal: 5,
    step: 1,
    repeatDays: [1, 2, 3, 4, 5, 6, 7],
    reminderTime: '07:00',
    archived: false,
    createdAt: '2026-10-01T00:00:00.000Z'
  };

  const bookHabit: Habit = {
    id: 'h_book',
    userId: 'u_1',
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
  };

  const mindHabit: Habit = {
    id: 'h_mind',
    userId: 'u_1',
    name: 'Meditasyon ve Nefes',
    icon: 'self_improvement',
    category: 'mind',
    unit: 'dk',
    dailyGoal: 15,
    step: 5,
    repeatDays: [1, 2, 3, 4, 5, 6, 7],
    reminderTime: '08:00',
    archived: false,
    createdAt: '2026-10-01T00:00:00.000Z'
  };

  it('1. Hiç log olmadığında tüm rozetler kilitli, ilerleme 0 ve açılma tarihi null olmalı', () => {
    const result = evaluateBadges({ habits: [dummyHabit], logs: [] });

    expect(result.totalCount).toBe(BADGE_DEFINITIONS.length);
    expect(result.unlockedCount).toBe(0);
    expect(result.newlyUnlockedBadge).toBeNull();

    for (const b of result.badges) {
      expect(b.isUnlocked).toBe(false);
      expect(b.progress).toBe(0);
      expect(b.progressPercent).toBe(0);
      expect(b.unlockedAt).toBeNull();
    }
  });

  it('2. İlk Adım rozeti: 1 tamamlanmış log ile açılmalı, uncompleted log açmamalı', () => {
    // completed = false durumu
    const uncompletedLog: HabitLog = {
      habitId: 'h_water',
      userId: 'u_1',
      date: '2026-10-01',
      amount: 500,
      completed: false
    };

    let result = evaluateBadges({ habits: [dummyHabit], logs: [uncompletedLog] });
    let firstStep = result.badges.find((b) => b.id === 'first_step')!;
    expect(firstStep.isUnlocked).toBe(false);
    expect(firstStep.progress).toBe(0);

    // completed = true durumu
    const completedLog: HabitLog = {
      habitId: 'h_water',
      userId: 'u_1',
      date: '2026-10-02',
      amount: 2000,
      completed: true
    };

    result = evaluateBadges({ habits: [dummyHabit], logs: [completedLog] });
    firstStep = result.badges.find((b) => b.id === 'first_step')!;
    expect(firstStep.isUnlocked).toBe(true);
    expect(firstStep.progress).toBe(1);
    expect(firstStep.progressPercent).toBe(100);
    expect(firstStep.unlockedAt).toBe('2026-10-02');
  });

  it('3. 7 Gün Zincir ve 14 Gün Demir İrade sınır testleri: 6 gün açmaz, 7 gün 7 Gün Zinciri açar, 13 gün 14 Günü açmaz', () => {
    const logs7Days: HabitLog[] = [];
    for (let i = 1; i <= 6; i++) {
      const dateStr = `2026-10-0${i}`;
      logs7Days.push({
        habitId: 'h_water',
        userId: 'u_1',
        date: dateStr,
        amount: 2000,
        completed: true
      });
    }

    // 6 gün testi
    let result = evaluateBadges({ habits: [dummyHabit], logs: logs7Days });
    let streak7 = result.badges.find((b) => b.id === 'streak_7')!;
    expect(streak7.isUnlocked).toBe(false);
    expect(streak7.progress).toBe(6);
    expect(streak7.progressPercent).toBe(86);
    expect(streak7.unlockedAt).toBeNull();

    // 7. gün eklenir
    logs7Days.push({
      habitId: 'h_water',
      userId: 'u_1',
      date: '2026-10-07',
      amount: 2000,
      completed: true
    });

    result = evaluateBadges({ habits: [dummyHabit], logs: logs7Days });
    streak7 = result.badges.find((b) => b.id === 'streak_7')!;
    let streak14 = result.badges.find((b) => b.id === 'streak_14')!;
    expect(streak7.isUnlocked).toBe(true);
    expect(streak7.progress).toBe(7);
    expect(streak7.progressPercent).toBe(100);
    expect(streak7.unlockedAt).toBe('2026-10-07');
    expect(streak14.isUnlocked).toBe(false);
    expect(streak14.progress).toBe(7);

    // 14 güne tamamlanır
    for (let i = 8; i <= 14; i++) {
      const dayStr = i < 10 ? `0${i}` : `${i}`;
      logs7Days.push({
        habitId: 'h_water',
        userId: 'u_1',
        date: `2026-10-${dayStr}`,
        amount: 2000,
        completed: true
      });
    }

    result = evaluateBadges({ habits: [dummyHabit], logs: logs7Days });
    streak14 = result.badges.find((b) => b.id === 'streak_14')!;
    expect(streak14.isUnlocked).toBe(true);
    expect(streak14.progress).toBe(14);
    expect(streak14.progressPercent).toBe(100);
    expect(streak14.unlockedAt).toBe('2026-10-14');
  });

  it('4. Kategori rozetleri (Su Pınarı, Kitap Kurdu, Maraton Ruhu, Zen Zihin) doğru filtrelemeli', () => {
    const logs: HabitLog[] = [];

    // 10 Su logu (Su Pınarı hedefi: 10)
    for (let i = 1; i <= 10; i++) {
      const day = i < 10 ? `0${i}` : `${i}`;
      logs.push({
        habitId: 'h_water',
        userId: 'u_1',
        date: `2026-10-${day}`,
        amount: 2000,
        completed: true
      });
    }

    // 5 Kitap logu (Kitap Kurdu hedefi: 10)
    for (let i = 1; i <= 5; i++) {
      const day = i < 10 ? `0${i}` : `${i}`;
      logs.push({
        habitId: 'h_book',
        userId: 'u_1',
        date: `2026-10-${day}`,
        amount: 20,
        completed: true
      });
    }

    // 21 Spor logu (Maraton Ruhu hedefi: 21)
    for (let i = 1; i <= 21; i++) {
      const day = i < 10 ? `0${i}` : `${i}`;
      logs.push({
        habitId: 'h_run',
        userId: 'u_1',
        date: `2026-10-${day}`,
        amount: 5,
        completed: true
      });
    }

    const habits = [dummyHabit, bookHabit, sportHabit, mindHabit];
    const result = evaluateBadges({ habits, logs });

    const waterBadge = result.badges.find((b) => b.id === 'water_spring')!;
    expect(waterBadge.isUnlocked).toBe(true);
    expect(waterBadge.unlockedAt).toBe('2026-10-10');

    const bookBadge = result.badges.find((b) => b.id === 'bookworm')!;
    expect(bookBadge.isUnlocked).toBe(false);
    expect(bookBadge.progress).toBe(5);
    expect(bookBadge.progressPercent).toBe(50);

    const marathonBadge = result.badges.find((b) => b.id === 'marathon_spirit')!;
    expect(marathonBadge.isUnlocked).toBe(true);
    expect(marathonBadge.progress).toBe(21);
    expect(marathonBadge.unlockedAt).toBe('2026-10-21');

    const zenBadge = result.badges.find((b) => b.id === 'zen_mind')!;
    expect(zenBadge.isUnlocked).toBe(false);
    expect(zenBadge.progress).toBe(0);
  });

  it('5. Loglar kronolojik sırada olmasa dahi açılma tarihi deterministik ve doğru hesaplanmalı', () => {
    // Karışık sıralı 10 su kaydı
    const shuffledDates = [
      '2026-10-10',
      '2026-10-02',
      '2026-10-08',
      '2026-10-01',
      '2026-10-05',
      '2026-10-09',
      '2026-10-04',
      '2026-10-03',
      '2026-10-07',
      '2026-10-06'
    ];

    const logs: HabitLog[] = shuffledDates.map((date) => ({
      habitId: 'h_water',
      userId: 'u_1',
      date,
      amount: 2000,
      completed: true
    }));

    const result = evaluateBadges({ habits: [dummyHabit], logs });
    const waterBadge = result.badges.find((b) => b.id === 'water_spring')!;
    expect(waterBadge.isUnlocked).toBe(true);
    // 10. kronolojik tarih '2026-10-10' olmalıdır
    expect(waterBadge.unlockedAt).toBe('2026-10-10');
  });

  it('6. calculateUserLevelWithBadges: Alışkanlık XP + Rozet bonus XP doğru toplanıp seviyeyi yükseltmeli', () => {
    const logs: HabitLog[] = [
      { habitId: 'h_water', userId: 'u_1', date: '2026-10-01', amount: 2000, completed: true }
    ];

    const badgeEvaluation = evaluateBadges({ habits: [dummyHabit], logs });
    const levelInfo = calculateUserLevelWithBadges(logs, badgeEvaluation.badges);

    // 1 log = 15 XP + İlk Adım rozeti (25 XP) = 40 XP
    expect(levelInfo.totalXp).toBe(40);
    expect(levelInfo.level).toBe(1);
    expect(levelInfo.title).toBe('Çırak');
    expect(levelInfo.nextLevelXp).toBe(100);
    expect(levelInfo.progressPercent).toBe(40);
  });
});
