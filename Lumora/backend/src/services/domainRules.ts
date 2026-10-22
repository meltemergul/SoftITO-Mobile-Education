import { Habit } from '../domain/habit.js';
import { HabitLog } from '../domain/habitLog.js';
import {
  calculateLevelFromXp,
  HABIT_COMPLETION_XP,
  LevelInfo
} from '../domain/constants.js';

/**
 * Belirtilen tarih ve saat diliminde YYYY-MM-DD biçiminde yerel gün metni döner.
 */
export function formatDateInTimezone(date: Date, timezone: string): string {
  try {
    const formatter = new Intl.DateTimeFormat('en-CA', {
      timeZone: timezone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    });
    return formatter.format(date);
  } catch {
    // Geçersiz saat dilimi durumunda varsayılan UTC'ye düşülür
    return date.toISOString().slice(0, 10);
  }
}

/**
 * YYYY-MM-DD biçimindeki bir tarihi verilen gün sayısı kadar öteler (pozitif ileri, negatif geri).
 * Ay ve yıl geçişlerini UTC aritmetiği ile güvenli şekilde hesaplar.
 */
export function shiftDateString(dateStr: string, daysOffset: number): string {
  const d = new Date(`${dateStr}T00:00:00.000Z`);
  d.setUTCDate(d.getUTCDate() + daysOffset);
  return d.toISOString().slice(0, 10);
}

/**
 * YYYY-MM-DD biçimindeki tarihin ISO-8601 gün numarasını döner (1: Pazartesi ... 7: Pazar).
 */
export function getDayOfWeek(dateStr: string): number {
  const d = new Date(`${dateStr}T00:00:00.000Z`);
  const day = d.getUTCDay();
  return day === 0 ? 7 : day;
}

/**
 * Bir alışkanlığın belirtilen tarihte planlı olup olmadığını kontrol eder.
 * Kural: repeatDays içinde olmalı ve alışkanlığın oluşturulma tarihinden önce olmamalıdır.
 */
export function isHabitPlannedOnDate(habit: Habit, dateStr: string): boolean {
  const createdDate = habit.createdAt.slice(0, 10);
  if (dateStr < createdDate) {
    return false;
  }
  const dayOfWeek = getDayOfWeek(dateStr);
  return habit.repeatDays.includes(dayOfWeek);
}

export interface StreakCalculationResult {
  currentStreak: number;
  longestStreak: number;
  freezesUsed: number;
  remainingFreezes: number;
  isCompletedToday: boolean;
  isPlannedToday: boolean;
}

/**
 * architecture-skill.md Bölüm 9'a göre seri hesaplama saf fonksiyonu.
 * - Planlı olmayan günler seriyi bozmaz ve atlanır.
 * - Bugün henüz bitmediği için tamamlanmamış olması seriyi bozmaz.
 * - Kaçırılan planlı günde dondurma hakkı varsa 1 hak harcanarak seri korunur.
 */
export function calculateHabitStreak(params: {
  habit: Habit;
  logs: HabitLog[];
  todayDateStr: string;
  availableFreezes?: number;
}): StreakCalculationResult {
  const { habit, logs, todayDateStr } = params;
  let remainingFreezes = Math.max(0, params.availableFreezes ?? 0);
  let freezesUsed = 0;

  // Tarihe göre log haritası
  const logMap = new Map<string, HabitLog>();
  for (const log of logs) {
    if (log.habitId === habit.id) {
      logMap.set(log.date, log);
    }
  }

  const isPlannedToday = isHabitPlannedOnDate(habit, todayDateStr);
  const todayLog = logMap.get(todayDateStr);
  const isCompletedToday = todayLog?.completed === true;

  // 1. MEVCUT SERİ (Current Streak) HESAPLAMA
  let currentStreak = 0;
  let checkDate: string;

  if (isPlannedToday) {
    if (isCompletedToday) {
      currentStreak = 1;
      checkDate = shiftDateString(todayDateStr, -1);
    } else {
      // Bugün henüz bitmediği için tamamlanmamış olması seriyi bozmaz.
      // Dünden geriye doğru sayılır.
      checkDate = shiftDateString(todayDateStr, -1);
    }
  } else {
    // Bugün planlı değil; dün ve gerisine bakılır
    checkDate = shiftDateString(todayDateStr, -1);
  }

  const createdDateStr = habit.createdAt.slice(0, 10);
  const maxLookbackDays = 730; // En fazla 2 yıl geriye bakılır
  let lookbackCounter = 0;

  while (checkDate >= createdDateStr && lookbackCounter < maxLookbackDays) {
    lookbackCounter++;

    if (isHabitPlannedOnDate(habit, checkDate)) {
      const log = logMap.get(checkDate);
      if (log && log.completed) {
        currentStreak++;
      } else {
        // Kaçırılmış planlı gün: Dondurma hakkı var mı?
        if (remainingFreezes > 0) {
          remainingFreezes--;
          freezesUsed++;
          currentStreak++;
        } else {
          // Hak yok, seri burada kesilir
          break;
        }
      }
    }
    // Planlı olmayan gün seriyi bozmaz, sadece bir gün geriye kayılır
    checkDate = shiftDateString(checkDate, -1);
  }

  // 2. EN UZUN SERİ (Longest Streak) HESAPLAMA
  // Tüm geçmiş loglardan kesintisiz tamamlanan planlı gün serisi hesaplanır.
  let longestStreak = currentStreak;
  let runningStreak = 0;

  // Logların tarihlerini ve başlangıç tarihini bul
  const sortedDates = Array.from(logMap.keys()).sort();
  if (sortedDates.length > 0) {
    let walkDate = sortedDates[0] < createdDateStr ? sortedDates[0] : createdDateStr;

    while (walkDate <= todayDateStr) {
      if (isHabitPlannedOnDate(habit, walkDate)) {
        const log = logMap.get(walkDate);
        if (log && log.completed) {
          runningStreak++;
          if (runningStreak > longestStreak) {
            longestStreak = runningStreak;
          }
        } else if (walkDate !== todayDateStr) {
          // Bugün hariç tamamlanmayan planlı gün runningStreak'i sıfırlar
          runningStreak = 0;
        }
      }
      walkDate = shiftDateString(walkDate, 1);
    }
  }

  return {
    currentStreak,
    longestStreak,
    freezesUsed,
    remainingFreezes,
    isCompletedToday,
    isPlannedToday
  };
}

export interface DailyProgressResult {
  completed: number;
  total: number;
  percentage: number;
  isAllCompleted: boolean;
}

/**
 * Günün ilerlemesini hesaplar: tamamlanan planlı alışkanlık / bugünkü planlı alışkanlık.
 */
export function calculateDailyProgress(
  totalPlanned: number,
  completedPlanned: number
): DailyProgressResult {
  if (totalPlanned <= 0) {
    return {
      completed: 0,
      total: 0,
      percentage: 100, // Dinlenme günü
      isAllCompleted: true
    };
  }

  const completed = Math.min(totalPlanned, Math.max(0, completedPlanned));
  const percentage = Math.round((completed / totalPlanned) * 100);

  return {
    completed,
    total: totalPlanned,
    percentage,
    isAllCompleted: completed === totalPlanned
  };
}

/**
 * Toplam XP ve seviye bilgisini hesaplar.
 * Kural: Her tamamlanmış log +15 XP verir. Geri alındığında completed log sayısı
 * azalacağı için XP kendiliğinden düşer.
 */
export function calculateUserXp(completedLogsCount: number, bonusXp = 0): LevelInfo {
  const totalXp = Math.max(0, completedLogsCount * HABIT_COMPLETION_XP + bonusXp);
  return calculateLevelFromXp(totalXp);
}
