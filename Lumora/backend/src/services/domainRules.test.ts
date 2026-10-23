import { describe, it, expect } from 'vitest';
import { Habit } from '../domain/habit.js';
import { HabitLog } from '../domain/habitLog.js';
import {
  calculateDailyProgress,
  calculateHabitStreak,
  calculateUserXp,
  formatDateInTimezone,
  shiftDateString
} from './domainRules.js';
import { HABIT_COMPLETION_XP } from '../domain/constants.js';

describe('Domain Kuralları (Bölüm 9) Saf Fonksiyon Birim Testleri', () => {
  const baseHabit: Habit = {
    id: 'hbt_test_1',
    userId: 'usr_1',
    name: 'Kitap Okuma',
    icon: 'menu_book',
    category: 'book',
    unit: 'sayfa',
    dailyGoal: 20,
    step: 5,
    repeatDays: [1, 2, 3, 4, 5, 6, 7], // Her gün
    reminderTime: '21:00',
    archived: false,
    createdAt: '2026-01-01T00:00:00.000Z'
  };

  it('1. Ay ve yıl geçişleri (shiftDateString): Tarih aritmetiği doğru çalışmalı', () => {
    // Yıl geçişi (31 Aralık -> 1 Ocak)
    expect(shiftDateString('2026-12-31', 1)).toBe('2027-01-01');
    expect(shiftDateString('2027-01-01', -1)).toBe('2026-12-31');

    // Ay geçişi (28 Şubat -> 1 Mart)
    expect(shiftDateString('2026-02-28', 1)).toBe('2026-03-01');
    expect(shiftDateString('2026-03-01', -1)).toBe('2026-02-28');

    // Artık yıl (2024 Şubat 29 gün)
    expect(shiftDateString('2024-02-28', 1)).toBe('2024-02-29');
    expect(shiftDateString('2024-02-29', 1)).toBe('2024-03-01');
  });

  it('2. Saat dilimi kontrolü (formatDateInTimezone): Kullanıcının timezone ayarına göre tarih belirlenmeli', () => {
    // UTC'de 2026-10-22 saat 22:30:00 iken Tokyo'da (UTC+9) tarih ertesi gündür (2026-10-23)
    const fixedTime = new Date('2026-10-22T22:30:00.000Z');

    const tokyoDate = formatDateInTimezone(fixedTime, 'Asia/Tokyo');
    expect(tokyoDate).toBe('2026-10-23');

    const nyDate = formatDateInTimezone(fixedTime, 'America/New_York');
    expect(nyDate).toBe('2026-10-22');

    const istanbulDate = formatDateInTimezone(fixedTime, 'Europe/Istanbul');
    // UTC 22:30 + 3 saat = 01:30 (ertesi gün)
    expect(istanbulDate).toBe('2026-10-23');
  });

  it('3. Planlı olmayan günlerin seriyi bozmaması (atlama kuralı)', () => {
    // Yalnızca Pazartesi (1), Çarşamba (3) ve Cuma (5) planlı bir alışkanlık
    const habitMWF: Habit = {
      ...baseHabit,
      repeatDays: [1, 3, 5],
      createdAt: '2026-10-01T00:00:00.000Z'
    };

    // 2026-10-19: Pazartesi (1) - completed: true
    // 2026-10-20: Salı (2) - planlı DEĞİL
    // 2026-10-21: Çarşamba (3) - completed: true
    // 2026-10-22: Perşembe (4) - planlı DEĞİL
    // 2026-10-23: Cuma (5) - completed: true (bugün)
    const logs: HabitLog[] = [
      { id: '1', userId: 'u1', habitId: habitMWF.id, date: '2026-10-19', amount: 20, completed: true, updatedAt: '' },
      { id: '2', userId: 'u1', habitId: habitMWF.id, date: '2026-10-21', amount: 20, completed: true, updatedAt: '' },
      { id: '3', userId: 'u1', habitId: habitMWF.id, date: '2026-10-23', amount: 20, completed: true, updatedAt: '' }
    ];

    const result = calculateHabitStreak({
      habit: habitMWF,
      logs,
      todayDateStr: '2026-10-23'
    });

    // Salı ve Perşembe planlı olmadığı için seri bozulmamalı, kesintisiz 3 planlı gün sayılmalı
    expect(result.currentStreak).toBe(3);
    expect(result.freezesUsed).toBe(0);
  });

  it('4. Bugün henüz bitmediği için tamamlanmamış olması seriyi bozmaz', () => {
    // Dün tamamlanmış, bugün ise henüz tamamlanmamış
    const logs: HabitLog[] = [
      { id: '1', userId: 'u1', habitId: baseHabit.id, date: '2026-10-21', amount: 20, completed: true, updatedAt: '' },
      { id: '2', userId: 'u1', habitId: baseHabit.id, date: '2026-10-22', amount: 5, completed: false, updatedAt: '' } // bugün eksik
    ];

    const result = calculateHabitStreak({
      habit: baseHabit,
      logs,
      todayDateStr: '2026-10-22'
    });

    // Bugün bitmediği için dünkü 1 serisi korunmalıdır
    expect(result.currentStreak).toBe(1);
    expect(result.isCompletedToday).toBe(false);
    expect(result.freezesUsed).toBe(0);
  });

  it('5. Kaçırılan planlı günde dondurma hakkının kullanılması', () => {
    // 2026-10-19: tamamlandı
    // 2026-10-20: KAÇIRILDI (planlı ama log yok/completed false)
    // 2026-10-21: tamamlandı
    // 2026-10-22: tamamlandı (bugün)
    const logs: HabitLog[] = [
      { id: '1', userId: 'u1', habitId: baseHabit.id, date: '2026-10-19', amount: 20, completed: true, updatedAt: '' },
      { id: '2', userId: 'u1', habitId: baseHabit.id, date: '2026-10-21', amount: 20, completed: true, updatedAt: '' },
      { id: '3', userId: 'u1', habitId: baseHabit.id, date: '2026-10-22', amount: 20, completed: true, updatedAt: '' }
    ];

    // Dondurma hakkı 1 varken:
    const withFreeze = calculateHabitStreak({
      habit: baseHabit,
      logs,
      todayDateStr: '2026-10-22',
      availableFreezes: 1
    });

    expect(withFreeze.freezesUsed).toBe(1);
    expect(withFreeze.remainingFreezes).toBe(0);
    expect(withFreeze.currentStreak).toBe(4); // 22, 21, 20 (donduruldu), 19

    // Dondurma hakkı 0 varken:
    const withoutFreeze = calculateHabitStreak({
      habit: baseHabit,
      logs,
      todayDateStr: '2026-10-22',
      availableFreezes: 0
    });

    expect(withoutFreeze.freezesUsed).toBe(0);
    // 20'sinde dondurma hakkı olmadığı için seri orada kesilir (22 ve 21 = 2)
    expect(withoutFreeze.currentStreak).toBe(2);
  });

  it('6. XP hesaplaması ve tamamlamayı geri almada XP düşmesi', () => {
    // 1 tamamlanmış log = 15 XP
    const xp1 = calculateUserXp(1);
    expect(xp1.totalXp).toBe(HABIT_COMPLETION_XP);
    expect(xp1.level).toBe(1);

    // 10 tamamlanmış log = 150 XP
    const xp10 = calculateUserXp(10);
    expect(xp10.totalXp).toBe(150);
    expect(xp10.level).toBe(2); // Level 2: 100 - 250 XP

    // Geri alma: completed count 10'dan 9'a düştüğünde
    const xpReverted = calculateUserXp(9);
    expect(xpReverted.totalXp).toBe(135);
    expect(xpReverted.totalXp).toBeLessThan(xp10.totalXp);
  });

  it('7. Günün ilerlemesi hesaplama', () => {
    // 4 planlıdan 3'ü bitti -> %75
    const p1 = calculateDailyProgress(4, 3);
    expect(p1.percentage).toBe(75);
    expect(p1.isAllCompleted).toBe(false);

    // 4 planlıdan 4'ü bitti -> %100 ve isAllCompleted
    const p2 = calculateDailyProgress(4, 4);
    expect(p2.percentage).toBe(100);
    expect(p2.isAllCompleted).toBe(true);

    // Bugün planlı görev yok -> dinlenme günü (%100)
    const pRest = calculateDailyProgress(0, 0);
    expect(pRest.percentage).toBe(100);
    expect(pRest.isAllCompleted).toBe(true);
  });
});
