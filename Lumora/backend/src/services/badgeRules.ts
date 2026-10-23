import { Habit } from '../domain/habit.js';
import { HabitLog } from '../domain/habitLog.js';
import { BadgeCategory, UserBadge, BadgesResponse } from '../domain/badge.js';
import {
  calculateLevelFromXp,
  HABIT_COMPLETION_XP,
  LevelInfo
} from '../domain/constants.js';
import { isHabitPlannedOnDate, shiftDateString } from './domainRules.js';

export interface BadgeDefinition {
  id: string;
  name: string;
  description: string;
  category: BadgeCategory;
  icon: string;
  xpReward: number;
  targetValue: number;
  unit: string;
}

export const BADGE_DEFINITIONS: readonly BadgeDefinition[] = [
  {
    id: 'first_step',
    name: 'İlk Adım',
    description: 'İlk alışkanlığını başarıyla tamamla.',
    category: 'streak',
    icon: 'flag_circle',
    xpReward: 25,
    targetValue: 1,
    unit: 'tamamlama'
  },
  {
    id: 'streak_7',
    name: '7 Gün Zincir',
    description: 'Bir alışkanlıkta kesintisiz 7 günlük zincir oluştur.',
    category: 'streak',
    icon: 'local_fire_department',
    xpReward: 50,
    targetValue: 7,
    unit: 'gün'
  },
  {
    id: 'streak_14',
    name: '14 Gün Demir İrade',
    description: 'Bir alışkanlıkta 14 günlük kesintisiz seri yakala.',
    category: 'streak',
    icon: 'shield',
    xpReward: 100,
    targetValue: 14,
    unit: 'gün'
  },
  {
    id: 'fire_passion',
    name: 'Alev Tutkunu',
    description: 'Toplamda 30 gün boyunca alışkanlık hedefini tamamla.',
    category: 'streak',
    icon: 'whatshot',
    xpReward: 150,
    targetValue: 30,
    unit: 'gün'
  },
  {
    id: 'water_spring',
    name: 'Su Pınarı',
    description: 'Su içme hedefini 10 gün boyunca eksiksiz yerine getir.',
    category: 'sport',
    icon: 'water_drop',
    xpReward: 75,
    targetValue: 10,
    unit: 'gün'
  },
  {
    id: 'marathon_spirit',
    name: 'Maraton Ruhu',
    description: 'Spor ve egzersiz alışkanlıklarında 21 kez hedefe ulaş.',
    category: 'sport',
    icon: 'directions_run',
    xpReward: 150,
    targetValue: 21,
    unit: 'gün'
  },
  {
    id: 'bookworm',
    name: 'Kitap Kurdu',
    description: 'Kitap okuma alışkanlığını 10 kez başarıyla tamamla.',
    category: 'mind',
    icon: 'menu_book',
    xpReward: 75,
    targetValue: 10,
    unit: 'gün'
  },
  {
    id: 'zen_mind',
    name: 'Zen Zihin',
    description: 'Zihin veya meditasyon alışkanlıklarını 15 kez tamamla.',
    category: 'mind',
    icon: 'self_improvement',
    xpReward: 100,
    targetValue: 15,
    unit: 'seans'
  },
  {
    id: 'master_disciplinarian',
    name: 'Usta Disiplinci',
    description: 'Toplam 50 alışkanlık tamamlamasına ulaşarak disiplinini kanıtla.',
    category: 'streak',
    icon: 'military_tech',
    xpReward: 250,
    targetValue: 50,
    unit: 'tamamlama'
  }
];

export interface EvaluateBadgesParams {
  habits: Habit[];
  logs: HabitLog[];
}

/**
 * Belirli bir alışkanlık için geçmişteki en uzun seriyi ve bu serinin ulaştığı en erken tarihi hesaplar.
 */
function evaluateHabitStreakHistory(
  habit: Habit,
  completedLogs: HabitLog[],
  targetStreak: number
): { maxStreak: number; reachedAt: string | null } {
  const habitCompletedLogs = completedLogs.filter((l) => l.habitId === habit.id);
  if (habitCompletedLogs.length === 0) {
    return { maxStreak: 0, reachedAt: null };
  }

  const completedDates = new Set(habitCompletedLogs.map((l) => l.date));
  const sortedDates = Array.from(completedDates).sort();
  const createdDateStr = habit.createdAt.slice(0, 10);
  const firstDate = sortedDates[0] < createdDateStr ? sortedDates[0] : createdDateStr;
  const lastDate = sortedDates[sortedDates.length - 1];

  let currentRunningStreak = 0;
  let maxStreak = 0;
  let reachedAt: string | null = null;

  let walkDate = firstDate;
  while (walkDate <= lastDate) {
    if (isHabitPlannedOnDate(habit, walkDate)) {
      if (completedDates.has(walkDate)) {
        currentRunningStreak++;
        if (currentRunningStreak > maxStreak) {
          maxStreak = currentRunningStreak;
        }
        if (currentRunningStreak >= targetStreak && reachedAt === null) {
          reachedAt = walkDate;
        }
      } else {
        currentRunningStreak = 0;
      }
    }
    walkDate = shiftDateString(walkDate, 1);
  }

  return { maxStreak, reachedAt };
}

/**
 * architecture-skill.md Bölüm 9'a göre rozetleri değerlendiren saf fonksiyon.
 * - Tanımlar kodda sabittir.
 * - Açılma tarihi loglardan hesaplanır, ayrıca saklanmaz.
 */
export function evaluateBadges(params: EvaluateBadgesParams): BadgesResponse {
  const { habits, logs } = params;

  // Sadece tamamlanmış (completed === true) kayıtları al ve tarihe göre kronolojik sırala
  const completedLogs = logs
    .filter((l) => l.completed === true)
    .sort((a, b) => a.date.localeCompare(b.date));

  // Alışkanlık id -> kategori haritası
  const habitMap = new Map<string, Habit>();
  for (const h of habits) {
    habitMap.set(h.id, h);
  }

  const evaluatedBadges: UserBadge[] = BADGE_DEFINITIONS.map((def) => {
    let progress = 0;
    let isUnlocked = false;
    let unlockedAt: string | null = null;

    switch (def.id) {
      case 'first_step': {
        // En az 1 tamamlanmış log
        progress = Math.min(completedLogs.length, def.targetValue);
        if (completedLogs.length >= def.targetValue) {
          isUnlocked = true;
          unlockedAt = completedLogs[0].date;
        }
        break;
      }

      case 'streak_7':
      case 'streak_14': {
        // Herhangi bir alışkanlıkta kesintisiz hedef gün serisi
        let highestStreak = 0;
        let earliestDate: string | null = null;

        for (const habit of habits) {
          const result = evaluateHabitStreakHistory(habit, completedLogs, def.targetValue);
          if (result.maxStreak > highestStreak) {
            highestStreak = result.maxStreak;
          }
          if (result.reachedAt) {
            if (!earliestDate || result.reachedAt < earliestDate) {
              earliestDate = result.reachedAt;
            }
          }
        }

        progress = Math.min(highestStreak, def.targetValue);
        isUnlocked = highestStreak >= def.targetValue;
        unlockedAt = isUnlocked ? earliestDate : null;
        break;
      }

      case 'fire_passion': {
        // Toplam 30 tekil tamamlanmış gün
        const distinctCompletedDays = Array.from(new Set(completedLogs.map((l) => l.date))).sort();
        progress = Math.min(distinctCompletedDays.length, def.targetValue);
        if (distinctCompletedDays.length >= def.targetValue) {
          isUnlocked = true;
          unlockedAt = distinctCompletedDays[def.targetValue - 1];
        }
        break;
      }

      case 'water_spring': {
        // Su kategorisindeki veya adı 'su' içeren alışkanlıklarda tamamlanma sayısı
        const matchingLogs = completedLogs.filter((l) => {
          const habit = habitMap.get(l.habitId);
          if (!habit) return false;
          const name = habit.name.toLowerCase();
          return (
            habit.category === 'water' ||
            name.startsWith('su') ||
            name.includes('su iç') ||
            name.includes('su tüket')
          );
        });
        progress = Math.min(matchingLogs.length, def.targetValue);
        if (matchingLogs.length >= def.targetValue) {
          isUnlocked = true;
          unlockedAt = matchingLogs[def.targetValue - 1].date;
        }
        break;
      }

      case 'marathon_spirit': {
        // Spor kategorisindeki veya adı spor/koşu/adım içeren alışkanlıklar
        const matchingLogs = completedLogs.filter((l) => {
          const habit = habitMap.get(l.habitId);
          if (!habit) return false;
          const name = habit.name.toLowerCase();
          return (
            habit.category === 'sport' ||
            name.includes('koşu') ||
            name.includes('spor') ||
            name.includes('adım') ||
            name.includes('egzersiz')
          );
        });
        progress = Math.min(matchingLogs.length, def.targetValue);
        if (matchingLogs.length >= def.targetValue) {
          isUnlocked = true;
          unlockedAt = matchingLogs[def.targetValue - 1].date;
        }
        break;
      }

      case 'bookworm': {
        // Kitap kategorisindeki veya adı 'kitap' içeren alışkanlıklar
        const matchingLogs = completedLogs.filter((l) => {
          const habit = habitMap.get(l.habitId);
          if (!habit) return false;
          return habit.category === 'book' || habit.name.toLowerCase().includes('kitap');
        });
        progress = Math.min(matchingLogs.length, def.targetValue);
        if (matchingLogs.length >= def.targetValue) {
          isUnlocked = true;
          unlockedAt = matchingLogs[def.targetValue - 1].date;
        }
        break;
      }

      case 'zen_mind': {
        // Zihin kategorisindeki veya meditasyon/uyku içeren alışkanlıklar
        const matchingLogs = completedLogs.filter((l) => {
          const habit = habitMap.get(l.habitId);
          if (!habit) return false;
          const name = habit.name.toLowerCase();
          return (
            habit.category === 'mind' ||
            name.includes('meditasyon') ||
            name.includes('uyku') ||
            name.includes('nefes')
          );
        });
        progress = Math.min(matchingLogs.length, def.targetValue);
        if (matchingLogs.length >= def.targetValue) {
          isUnlocked = true;
          unlockedAt = matchingLogs[def.targetValue - 1].date;
        }
        break;
      }

      case 'master_disciplinarian': {
        // Toplam 50 tamamlanma
        progress = Math.min(completedLogs.length, def.targetValue);
        if (completedLogs.length >= def.targetValue) {
          isUnlocked = true;
          unlockedAt = completedLogs[def.targetValue - 1].date;
        }
        break;
      }

      default:
        break;
    }

    const progressPercent = Math.min(
      100,
      Math.max(0, Math.round((progress / def.targetValue) * 100))
    );

    return {
      id: def.id,
      name: def.name,
      description: def.description,
      category: def.category,
      icon: def.icon,
      xpReward: def.xpReward,
      targetValue: def.targetValue,
      unit: def.unit,
      isUnlocked,
      unlockedAt,
      progress,
      maxProgress: def.targetValue,
      progressPercent
    };
  });

  const unlockedBadges = evaluatedBadges.filter((b) => b.isUnlocked);
  // En son açılan rozet (unlockedAt en büyük olan)
  let newlyUnlockedBadge: UserBadge | null = null;
  if (unlockedBadges.length > 0) {
    const sortedByUnlock = [...unlockedBadges].sort((a, b) =>
      (b.unlockedAt || '').localeCompare(a.unlockedAt || '')
    );
    newlyUnlockedBadge = sortedByUnlock[0];
  }

  return {
    badges: evaluatedBadges,
    unlockedCount: unlockedBadges.length,
    totalCount: evaluatedBadges.length,
    newlyUnlockedBadge: newlyUnlockedBadge ?? null
  };
}

/**
 * Toplam XP ve seviye bilgisini loglar ve rozet bonusları ile hesaplar.
 */
export function calculateUserLevelWithBadges(
  logs: HabitLog[],
  badges: UserBadge[]
): LevelInfo {
  const completedCount = logs.filter((l) => l.completed === true).length;
  const baseLogXp = completedCount * HABIT_COMPLETION_XP;
  const badgeBonusXp = badges
    .filter((b) => b.isUnlocked)
    .reduce((sum, b) => sum + b.xpReward, 0);

  const totalXp = baseLogXp + badgeBonusXp;
  return calculateLevelFromXp(totalXp);
}
