import { Habit } from '../domain/habit.js';
import { HabitLog } from '../domain/habitLog.js';
import {
  ActiveHabitChain,
  CalendarDayDetailHabit,
  CalendarDayDetailResponse,
  CalendarDaySummary,
  CalendarMonthResponse,
  DayStatus,
  HabitMicroDay
} from '../domain/calendar.js';
import {
  calculateHabitStreak,
  isHabitPlannedOnDate,
  shiftDateString
} from './domainRules.js';

export interface CalendarMonthCalculationParams {
  month: string; // YYYY-MM
  habits: Habit[];
  logs: HabitLog[];
  todayDateStr: string;
  streakFreezeCount?: number;
}

export function calculateMonthCalendar(params: CalendarMonthCalculationParams): CalendarMonthResponse {
  const { month, habits, logs, todayDateStr, streakFreezeCount } = params;

  // Log hızlı arama haritası: `${habitId}:${date}` -> HabitLog
  const logMap = new Map<string, HabitLog>();
  for (const log of logs) {
    logMap.set(`${log.habitId}:${log.date}`, log);
  }

  const [yearStr, monthNumStr] = month.split('-');
  const year = parseInt(yearStr, 10);
  const monthNum = parseInt(monthNumStr, 10);

  // Ayın gün sayısını hesapla (UTC)
  const totalDaysInMonth = new Date(Date.UTC(year, monthNum, 0)).getUTCDate();

  const days: CalendarDaySummary[] = [];
  let unbrokenDays = 0;

  for (let day = 1; day <= totalDaysInMonth; day++) {
    const dayFormatted = day < 10 ? `0${day}` : `${day}`;
    const dateStr = `${month}-${dayFormatted}`;
    const isToday = dateStr === todayDateStr;
    const isFuture = dateStr > todayDateStr;

    if (isFuture) {
      days.push({
        date: dateStr,
        status: 'future',
        totalPlanned: 0,
        completedCount: 0,
        isToday: false
      });
      continue;
    }

    // O günde planlı olan aktif alışkanlıkları bul
    const plannedHabits = habits.filter((h) => !h.archived && isHabitPlannedOnDate(h, dateStr));
    const totalPlanned = plannedHabits.length;

    if (totalPlanned === 0) {
      days.push({
        date: dateStr,
        status: 'rest',
        totalPlanned: 0,
        completedCount: 0,
        isToday
      });
      continue;
    }

    let completedCount = 0;
    let anyProgress = false;

    for (const habit of plannedHabits) {
      const log = logMap.get(`${habit.id}:${dateStr}`);
      if (log) {
        if (log.completed) {
          completedCount++;
        }
        if (log.amount > 0 || log.completed) {
          anyProgress = true;
        }
      }
    }

    let status: DayStatus = 'empty';
    if (completedCount === totalPlanned) {
      status = 'completed';
      unbrokenDays++;
    } else if (completedCount > 0 || anyProgress) {
      status = 'partial';
    } else {
      status = 'empty';
    }

    days.push({
      date: dateStr,
      status,
      totalPlanned,
      completedCount,
      isToday
    });
  }

  // En uzun seriyi hesapla
  let maxLongestStreak = 0;
  const activeHabits: ActiveHabitChain[] = [];

  const nonArchivedHabits = habits.filter((h) => !h.archived);

  for (const habit of nonArchivedHabits) {
    const streakInfo = calculateHabitStreak({
      habit,
      logs,
      todayDateStr,
      availableFreezes: streakFreezeCount ?? 0
    });

    if (streakInfo.longestStreak > maxLongestStreak) {
      maxLongestStreak = streakInfo.longestStreak;
    }

    // Ay içindeki tamamlanma oranını hesapla
    let habitMonthPlannedCount = 0;
    let habitMonthCompletedCount = 0;

    for (let day = 1; day <= totalDaysInMonth; day++) {
      const dayFormatted = day < 10 ? `0${day}` : `${day}`;
      const dateStr = `${month}-${dayFormatted}`;
      if (dateStr > todayDateStr) continue;

      if (isHabitPlannedOnDate(habit, dateStr)) {
        habitMonthPlannedCount++;
        const log = logMap.get(`${habit.id}:${dateStr}`);
        if (log && log.completed) {
          habitMonthCompletedCount++;
        }
      }
    }

    const completionRate =
      habitMonthPlannedCount > 0
        ? Math.round((habitMonthCompletedCount / habitMonthPlannedCount) * 100)
        : 0;

    // Son 7 günün mikro zincir halkaları (bugün dahil geriye doğru 7 gün, kronolojik sırada)
    const last7Days: HabitMicroDay[] = [];
    for (let i = 6; i >= 0; i--) {
      const dayDate = shiftDateString(todayDateStr, -i);
      const isPlanned = isHabitPlannedOnDate(habit, dayDate);
      const log = logMap.get(`${habit.id}:${dayDate}`);
      const isCompleted = log ? log.completed : false;

      last7Days.push({
        date: dayDate,
        isPlanned,
        isCompleted
      });
    }

    activeHabits.push({
      id: habit.id,
      name: habit.name,
      icon: habit.icon,
      category: habit.category,
      completionRate,
      currentStreak: streakInfo.currentStreak,
      last7Days
    });
  }

  return {
    month,
    unbrokenDays,
    longestStreak: maxLongestStreak,
    days,
    activeHabits
  };
}

export interface CalendarDayDetailParams {
  dateStr: string;
  habits: Habit[];
  logs: HabitLog[];
  todayDateStr: string;
}

export function calculateDayDetail(params: CalendarDayDetailParams): CalendarDayDetailResponse {
  const { dateStr, habits, logs, todayDateStr } = params;

  const logMap = new Map<string, HabitLog>();
  for (const log of logs) {
    if (log.date === dateStr) {
      logMap.set(log.habitId, log);
    }
  }

  const isFuture = dateStr > todayDateStr;
  const nonArchivedHabits = habits.filter((h) => !h.archived);

  const detailHabits: CalendarDayDetailHabit[] = [];
  let totalPlanned = 0;
  let completedCount = 0;
  let anyProgress = false;

  for (const habit of nonArchivedHabits) {
    const isPlanned = isHabitPlannedOnDate(habit, dateStr);
    const log = logMap.get(habit.id);
    const isCompleted = log ? log.completed : false;
    const currentAmount = log ? log.amount : 0;

    if (isPlanned) {
      totalPlanned++;
      if (isCompleted) {
        completedCount++;
      }
      if (currentAmount > 0 || isCompleted) {
        anyProgress = true;
      }
    }

    detailHabits.push({
      id: habit.id,
      name: habit.name,
      icon: habit.icon,
      category: habit.category,
      unit: habit.unit,
      dailyGoal: habit.dailyGoal,
      step: habit.step,
      isPlanned,
      isCompleted,
      currentAmount,
      targetAmount: habit.dailyGoal
    });
  }

  let status: DayStatus = 'empty';
  if (isFuture) {
    status = 'future';
  } else if (totalPlanned === 0) {
    status = 'rest';
  } else if (completedCount === totalPlanned) {
    status = 'completed';
  } else if (completedCount > 0 || anyProgress) {
    status = 'partial';
  } else {
    status = 'empty';
  }

  return {
    date: dateStr,
    status,
    totalPlanned,
    completedCount,
    habits: detailHabits
  };
}
