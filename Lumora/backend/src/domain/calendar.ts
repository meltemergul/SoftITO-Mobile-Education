import { z } from 'zod';

export type DayStatus = 'completed' | 'partial' | 'empty' | 'rest' | 'future';

export const dayStatusSchema = z.enum(['completed', 'partial', 'empty', 'rest', 'future']);

export interface CalendarDaySummary {
  date: string;
  status: DayStatus;
  totalPlanned: number;
  completedCount: number;
  isToday: boolean;
}

export interface HabitMicroDay {
  date: string;
  isPlanned: boolean;
  isCompleted: boolean;
}

export interface ActiveHabitChain {
  id: string;
  name: string;
  icon: string;
  category: string;
  completionRate: number;
  currentStreak: number;
  last7Days: HabitMicroDay[];
}

export interface CalendarMonthResponse {
  month: string;
  unbrokenDays: number;
  longestStreak: number;
  days: CalendarDaySummary[];
  activeHabits: ActiveHabitChain[];
}

export interface CalendarDayDetailHabit {
  id: string;
  name: string;
  icon: string;
  category: string;
  unit: string | null;
  dailyGoal: number;
  step: number;
  isPlanned: boolean;
  isCompleted: boolean;
  currentAmount: number;
  targetAmount: number;
}

export interface CalendarDayDetailResponse {
  date: string;
  status: DayStatus;
  totalPlanned: number;
  completedCount: number;
  habits: CalendarDayDetailHabit[];
}
