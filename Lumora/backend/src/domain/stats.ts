import { z } from 'zod';

export type StatsRange = 'weekly' | 'monthly' | 'all';

export const statsRangeSchema = z.enum(['weekly', 'monthly', 'all']);

export interface DailyChartItem {
  date: string;
  dayLabel: string;
  rate: number;
  completed: number;
  total: number;
  isPeak: boolean;
}

export interface CategoryDistribution {
  category: string;
  name: string;
  rate: number;
  completedCount: number;
  totalPlanned: number;
}

export interface ProductiveHourWindow {
  period: string;
  label: string;
  percentage: number;
  count: number;
}

export interface BestHabitDto {
  id: string;
  name: string;
  icon: string;
  category: string;
  rate: number;
  currentStreak: number;
}

export interface HabitProgressDetail {
  id: string;
  name: string;
  icon: string;
  category: string;
  rate: number;
  completedDays: number;
  totalPlannedDays: number;
  currentStreak: number;
  longestStreak: number;
}

export interface StatsResponse {
  range: StatsRange;
  hasEnoughData: boolean;
  overallScore: number;
  trend: number | null;
  dailyChart: DailyChartItem[];
  categoryDistribution: CategoryDistribution[];
  productiveHours: ProductiveHourWindow[];
  bestHabit: BestHabitDto | null;
  overallStreak: number;
  longestStreak: number;
  totalCompletedDays: number;
  habitProgress: HabitProgressDetail[];
}
