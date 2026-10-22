export const HABIT_COMPLETION_XP = 15;

export interface LevelThreshold {
  level: number;
  minXp: number;
  maxXp: number;
  title: string;
}

export const LEVEL_THRESHOLDS: readonly LevelThreshold[] = [
  { level: 1, minXp: 0, maxXp: 100, title: 'Çırak' },
  { level: 2, minXp: 100, maxXp: 250, title: 'İstikrarlı Başlangıç' },
  { level: 3, minXp: 250, maxXp: 500, title: 'Rutin Takipçisi' },
  { level: 4, minXp: 500, maxXp: 900, title: 'Disiplin Yolcusu' },
  { level: 5, minXp: 900, maxXp: 1500, title: 'Zincir Ustası' },
  { level: 6, minXp: 1500, maxXp: 2300, title: 'İrade Mimarı' },
  { level: 7, minXp: 2300, maxXp: 3300, title: 'Alışkanlık Mimarı' },
  { level: 8, minXp: 3300, maxXp: 4600, title: 'Odak Üstadı' },
  { level: 9, minXp: 4600, maxXp: 6200, title: 'Demir İrade' },
  { level: 10, minXp: 6200, maxXp: 100000, title: 'Efsanevi Disiplin' }
];

export interface LevelInfo {
  level: number;
  title: string;
  totalXp: number;
  currentLevelXp: number;
  nextLevelXp: number;
  progressPercent: number;
}

export function calculateLevelFromXp(totalXp: number): LevelInfo {
  const safeXp = Math.max(0, totalXp);
  const currentThreshold =
    LEVEL_THRESHOLDS.find((t) => safeXp >= t.minXp && safeXp < t.maxXp) ||
    LEVEL_THRESHOLDS[LEVEL_THRESHOLDS.length - 1];

  const currentLevelXp = safeXp - currentThreshold.minXp;
  const levelSpan = currentThreshold.maxXp - currentThreshold.minXp;
  const progressPercent = Math.min(
    100,
    Math.max(0, Math.round((currentLevelXp / levelSpan) * 100))
  );

  return {
    level: currentThreshold.level,
    title: currentThreshold.title,
    totalXp: safeXp,
    currentLevelXp: safeXp,
    nextLevelXp: currentThreshold.maxXp,
    progressPercent
  };
}
