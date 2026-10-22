import { HabitRepository } from '../repositories/habitRepository.js';
import { HabitLogRepository } from '../repositories/habitLogRepository.js';
import { UserSettingsRepository } from '../repositories/settingsRepository.js';
import {
  calculateDailyProgress,
  calculateHabitStreak,
  calculateUserXp,
  formatDateInTimezone,
  isHabitPlannedOnDate
} from './domainRules.js';
import { LevelInfo } from '../domain/constants.js';

export interface TodayHabitDto {
  id: string;
  name: string;
  icon: string;
  category: string;
  unit: string | null;
  dailyGoal: number;
  step: number;
  reminderTime: string | null;
  repeatDays: number[];
  isPlannedToday: boolean;
  isCompletedToday: boolean;
  currentAmount: number;
  currentStreak: number;
}

export interface TodayResponse {
  date: string;
  timezone: string;
  progress: {
    completed: number;
    total: number;
    percentage: number;
    isAllCompleted: boolean;
  };
  xp: LevelInfo;
  overallStreak: number;
  streakFreezeCount: number;
  habits: TodayHabitDto[];
}

export class TodayService {
  constructor(
    private habitRepository: HabitRepository,
    private habitLogRepository: HabitLogRepository,
    private settingsRepository: UserSettingsRepository
  ) {}

  public async getToday(userId: string): Promise<TodayResponse> {
    const settings = await this.settingsRepository.getByUserId(userId);
    const todayStr = formatDateInTimezone(new Date(), settings.timezone);

    // Aktif alışkanlıklar
    const habits = await this.habitRepository.listByUser(userId, false);

    // Kullanıcının tüm logları (streak ve XP hesabı için)
    const allLogs = await this.habitLogRepository.listByUserAndDateRange(userId);

    let totalPlanned = 0;
    let completedPlanned = 0;
    let totalFreezesUsed = 0;
    let maxHabitStreak = 0;

    const todayHabits: TodayHabitDto[] = habits.map((habit) => {
      const isPlanned = isHabitPlannedOnDate(habit, todayStr);
      const streakInfo = calculateHabitStreak({
        habit,
        logs: allLogs,
        todayDateStr: todayStr,
        availableFreezes: settings.streakFreezeCount
      });

      if (isPlanned) {
        totalPlanned++;
        if (streakInfo.isCompletedToday) {
          completedPlanned++;
        }
      }

      if (streakInfo.freezesUsed > 0) {
        totalFreezesUsed += streakInfo.freezesUsed;
      }

      if (streakInfo.currentStreak > maxHabitStreak) {
        maxHabitStreak = streakInfo.currentStreak;
      }

      const todayLog = allLogs.find(
        (l) => l.habitId === habit.id && l.date === todayStr
      );

      return {
        id: habit.id,
        name: habit.name,
        icon: habit.icon,
        category: habit.category,
        unit: habit.unit,
        dailyGoal: habit.dailyGoal,
        step: habit.step,
        reminderTime: habit.reminderTime,
        repeatDays: habit.repeatDays,
        isPlannedToday: isPlanned,
        isCompletedToday: streakInfo.isCompletedToday,
        currentAmount: todayLog ? todayLog.amount : 0,
        currentStreak: streakInfo.currentStreak
      };
    });

    // Günün ilerlemesi
    const progress = calculateDailyProgress(totalPlanned, completedPlanned);

    // Toplam tamamlanmış log sayısı (tüm zamanlar)
    const totalCompletedLogs = allLogs.filter((l) => l.completed).length;
    const xpInfo = calculateUserXp(totalCompletedLogs);

    // Kullanılan dondurma hakkı varsa ayarlarda güncelle
    if (totalFreezesUsed > 0 && settings.streakFreezeCount > 0) {
      const newFreezeCount = Math.max(0, settings.streakFreezeCount - totalFreezesUsed);
      await this.settingsRepository.update(userId, {
        streakFreezeCount: newFreezeCount
      });
      settings.streakFreezeCount = newFreezeCount;
    }

    return {
      date: todayStr,
      timezone: settings.timezone,
      progress,
      xp: xpInfo,
      overallStreak: maxHabitStreak,
      streakFreezeCount: settings.streakFreezeCount,
      habits: todayHabits
    };
  }
}
