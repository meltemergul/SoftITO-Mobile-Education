import { Habit } from '../domain/habit.js';
import { HabitLog } from '../domain/habitLog.js';
import {
  BestHabitDto,
  CategoryDistribution,
  DailyChartItem,
  HabitProgressDetail,
  ProductiveHourWindow,
  StatsRange,
  StatsResponse
} from '../domain/stats.js';
import {
  calculateHabitStreak,
  getDayOfWeek,
  isHabitPlannedOnDate,
  shiftDateString
} from './domainRules.js';

export interface CalculateStatsParams {
  range: StatsRange;
  habits: Habit[];
  logs: HabitLog[];
  todayDateStr: string;
  streakFreezeCount?: number;
  timezone?: string;
}

const TURKISH_DAY_NAMES: Record<number, string> = {
  1: 'Pzt',
  2: 'Sal',
  3: 'Çar',
  4: 'Per',
  5: 'Cum',
  6: 'Cmt',
  7: 'Paz'
};

const CATEGORY_NAMES: Record<string, string> = {
  water: 'Su',
  book: 'Kitap',
  sport: 'Spor ve Egzersiz',
  mind: 'Zihin & Meditasyon',
  custom: 'Özel'
};

export function calculateStats(params: CalculateStatsParams): StatsResponse {
  const { range, habits, logs, todayDateStr, streakFreezeCount = 0, timezone = 'Europe/Istanbul' } = params;

  const nonArchivedHabits = habits.filter((h) => !h.archived);

  // Log haritası: `${habitId}:${date}` -> HabitLog
  const logMap = new Map<string, HabitLog>();
  for (const log of logs) {
    logMap.set(`${log.habitId}:${log.date}`, log);
  }

  // 1. Aralıktaki günleri belirle
  const currentPeriodDates: string[] = [];
  const previousPeriodDates: string[] = [];

  let daysCount = 7;
  if (range === 'monthly') {
    daysCount = 30;
  } else if (range === 'all') {
    // Tüm geçmiş: en eski alışkanlık veya log tarihi
    let earliestDate = todayDateStr;
    for (const h of habits) {
      const cDate = h.createdAt.slice(0, 10);
      if (cDate < earliestDate) earliestDate = cDate;
    }
    for (const l of logs) {
      if (l.date < earliestDate) earliestDate = l.date;
    }

    // Tarih farkını gün olarak bul
    const dStart = new Date(`${earliestDate}T00:00:00.000Z`);
    const dEnd = new Date(`${todayDateStr}T00:00:00.000Z`);
    const diffTime = Math.max(0, dEnd.getTime() - dStart.getTime());
    daysCount = Math.max(7, Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1);
  }

  // Cari dönem tarihleri (kronolojik: geçmişten bugüne)
  for (let i = daysCount - 1; i >= 0; i--) {
    currentPeriodDates.push(shiftDateString(todayDateStr, -i));
  }

  // Önceki dönem tarihleri (weekly ve monthly için)
  if (range !== 'all') {
    for (let i = daysCount * 2 - 1; i >= daysCount; i--) {
      previousPeriodDates.push(shiftDateString(todayDateStr, -i));
    }
  }

  // 2. Cari dönem başarı oranı ve planlı gün hesaplama
  let totalPlanned = 0;
  let totalCompleted = 0;

  for (const dateStr of currentPeriodDates) {
    for (const habit of nonArchivedHabits) {
      if (isHabitPlannedOnDate(habit, dateStr)) {
        totalPlanned++;
        const log = logMap.get(`${habit.id}:${dateStr}`);
        if (log && log.completed) {
          totalCompleted++;
        }
      }
    }
  }

  const overallScore = totalPlanned > 0 ? Math.round((totalCompleted / totalPlanned) * 100) : 0;

  // 3. Önceki dönem başarı oranı ve trend hesaplama
  let trend: number | null = null;
  if (range !== 'all' && previousPeriodDates.length > 0) {
    let prevPlanned = 0;
    let prevCompleted = 0;

    for (const dateStr of previousPeriodDates) {
      for (const habit of nonArchivedHabits) {
        if (isHabitPlannedOnDate(habit, dateStr)) {
          prevPlanned++;
          const log = logMap.get(`${habit.id}:${dateStr}`);
          if (log && log.completed) {
            prevCompleted++;
          }
        }
      }
    }

    if (prevPlanned > 0) {
      const prevScore = Math.round((prevCompleted / prevPlanned) * 100);
      trend = overallScore - prevScore;
    }
  }

  // 4. Günlük çubuk grafik verisi (Son 7 gün için gün adı bazında, diğerleri için son 7 gün)
  const chartDates = range === 'weekly'
    ? currentPeriodDates
    : currentPeriodDates.slice(-7); // Grafikte 7 sütun odaklı gösterim

  let maxDailyRate = 0;
  const rawChartItems: { date: string; dayLabel: string; rate: number; completed: number; total: number }[] = [];

  for (const dateStr of chartDates) {
    let dayPlanned = 0;
    let dayCompleted = 0;

    for (const habit of nonArchivedHabits) {
      if (isHabitPlannedOnDate(habit, dateStr)) {
        dayPlanned++;
        const log = logMap.get(`${habit.id}:${dateStr}`);
        if (log && log.completed) {
          dayCompleted++;
        }
      }
    }

    const dayOfWeek = getDayOfWeek(dateStr);
    const dayLabel = TURKISH_DAY_NAMES[dayOfWeek] || '';
    const rate = dayPlanned > 0 ? Math.round((dayCompleted / dayPlanned) * 100) : 0;

    if (rate > maxDailyRate) {
      maxDailyRate = rate;
    }

    rawChartItems.push({
      date: dateStr,
      dayLabel,
      rate,
      completed: dayCompleted,
      total: dayPlanned
    });
  }

  const dailyChart: DailyChartItem[] = rawChartItems.map((item) => ({
    ...item,
    isPeak: maxDailyRate > 0 && item.rate === maxDailyRate
  }));

  // 5. Kategori Dağılımı
  const categoryStatsMap = new Map<string, { completed: number; total: number }>();

  for (const dateStr of currentPeriodDates) {
    for (const habit of nonArchivedHabits) {
      if (isHabitPlannedOnDate(habit, dateStr)) {
        const cat = habit.category;
        const currentCat = categoryStatsMap.get(cat) || { completed: 0, total: 0 };
        currentCat.total++;
        const log = logMap.get(`${habit.id}:${dateStr}`);
        if (log && log.completed) {
          currentCat.completed++;
        }
        categoryStatsMap.set(cat, currentCat);
      }
    }
  }

  const categoryDistribution: CategoryDistribution[] = [];
  for (const [catKey, catVal] of categoryStatsMap.entries()) {
    const rate = catVal.total > 0 ? Math.round((catVal.completed / catVal.total) * 100) : 0;
    categoryDistribution.push({
      category: catKey,
      name: CATEGORY_NAMES[catKey] || catKey,
      rate,
      completedCount: catVal.completed,
      totalPlanned: catVal.total
    });
  }
  // En yüksek orana göre sırala
  categoryDistribution.sort((a, b) => b.rate - a.rate);

  // 6. En Verimli Saatler (log.updatedAt'e göre)
  // Sabah (06-12), Öğle (12-18), Akşam (18-24), Gece (00-06)
  const timeSlotCounts: Record<string, { label: string; count: number }> = {
    morning: { label: 'Sabah (06:00 - 12:00)', count: 0 },
    afternoon: { label: 'Öğle (12:00 - 18:00)', count: 0 },
    evening: { label: 'Akşam (18:00 - 24:00)', count: 0 },
    night: { label: 'Gece (00:00 - 06:00)', count: 0 }
  };

  let totalLoggedActions = 0;
  for (const log of logs) {
    // Sadece cari dönem içindeki loglar
    if (currentPeriodDates.includes(log.date) && log.updatedAt) {
      try {
        const d = new Date(log.updatedAt);
        // Zaman dilimi formatı
        const hourStr = new Intl.DateTimeFormat('en-US', {
          timeZone: timezone,
          hour: 'numeric',
          hour12: false
        }).format(d);
        const hour = parseInt(hourStr, 10);

        if (hour >= 6 && hour < 12) {
          timeSlotCounts.morning.count++;
        } else if (hour >= 12 && hour < 18) {
          timeSlotCounts.afternoon.count++;
        } else if (hour >= 18 && hour < 24) {
          timeSlotCounts.evening.count++;
        } else {
          timeSlotCounts.night.count++;
        }
        totalLoggedActions++;
      } catch {
        // Hatalı tarih durumunda atla
      }
    }
  }

  const productiveHours: ProductiveHourWindow[] = Object.entries(timeSlotCounts)
    .filter(([_, val]) => val.count > 0)
    .map(([key, val]) => ({
      period: key,
      label: val.label,
      percentage: totalLoggedActions > 0 ? Math.round((val.count / totalLoggedActions) * 100) : 0,
      count: val.count
    }))
    .sort((a, b) => b.count - a.count);

  // 7. Alışkanlık Bazında İlerleme & En Düzenli Alışkanlık
  const habitProgress: HabitProgressDetail[] = [];
  let maxHabitOverallStreak = 0;
  let maxHabitLongestStreak = 0;

  for (const habit of nonArchivedHabits) {
    let habitPlanned = 0;
    let habitCompleted = 0;

    for (const dateStr of currentPeriodDates) {
      if (isHabitPlannedOnDate(habit, dateStr)) {
        habitPlanned++;
        const log = logMap.get(`${habit.id}:${dateStr}`);
        if (log && log.completed) {
          habitCompleted++;
        }
      }
    }

    const streakInfo = calculateHabitStreak({
      habit,
      logs,
      todayDateStr,
      availableFreezes: streakFreezeCount
    });

    if (streakInfo.currentStreak > maxHabitOverallStreak) {
      maxHabitOverallStreak = streakInfo.currentStreak;
    }
    if (streakInfo.longestStreak > maxHabitLongestStreak) {
      maxHabitLongestStreak = streakInfo.longestStreak;
    }

    const rate = habitPlanned > 0 ? Math.round((habitCompleted / habitPlanned) * 100) : 0;

    habitProgress.push({
      id: habit.id,
      name: habit.name,
      icon: habit.icon,
      category: habit.category,
      rate,
      completedDays: habitCompleted,
      totalPlannedDays: habitPlanned,
      currentStreak: streakInfo.currentStreak,
      longestStreak: streakInfo.longestStreak
    });
  }

  // En düzenli alışkanlık kuralı (architecture-skill.md Bölüm 9):
  // "aralıktaki en yüksek başarı oranına sahip alışkanlıktır; eşitlikte daha uzun mevcut seri kazanır."
  let bestHabit: BestHabitDto | null = null;
  const eligibleHabits = habitProgress.filter((h) => h.totalPlannedDays > 0);

  if (eligibleHabits.length > 0) {
    eligibleHabits.sort((a, b) => {
      if (b.rate !== a.rate) {
        return b.rate - a.rate;
      }
      return b.currentStreak - a.currentStreak;
    });

    const top = eligibleHabits[0];
    if (top.completedDays > 0) {
      bestHabit = {
        id: top.id,
        name: top.name,
        icon: top.icon,
        category: top.category,
        rate: top.rate,
        currentStreak: top.currentStreak
      };
    }
  }

  // 8. Toplam tamamlanan gün sayısı (seçili aralıkta en az 1 tamamlanmış planlı alışkanlığı olan tekil günler)
  const completedDaysSet = new Set<string>();
  for (const dateStr of currentPeriodDates) {
    for (const habit of nonArchivedHabits) {
      const log = logMap.get(`${habit.id}:${dateStr}`);
      if (log && log.completed) {
        completedDaysSet.add(dateStr);
      }
    }
  }
  const totalCompletedDays = completedDaysSet.size;

  // Veri yeterli mi? (En az 1 planlı gün ve en az 1 tamamlanmış log olmalı)
  const hasEnoughData = totalPlanned > 0 && totalCompleted > 0;

  return {
    range,
    hasEnoughData,
    overallScore,
    trend,
    dailyChart,
    categoryDistribution,
    productiveHours,
    bestHabit,
    overallStreak: maxHabitOverallStreak,
    longestStreak: maxHabitLongestStreak,
    totalCompletedDays,
    habitProgress
  };
}
