import { z } from 'zod';

export const habitCategorySchema = z.enum(['water', 'book', 'sport', 'mind', 'custom']);
export type HabitCategory = z.infer<typeof habitCategorySchema>;

export const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;

export const habitSchema = z.object({
  id: z.string(),
  userId: z.string(),
  name: z.string().trim().min(1, 'Alışkanlık adı boş olamaz.'),
  icon: z.string().trim().min(1, 'İkon adı boş olamaz.'),
  category: habitCategorySchema,
  unit: z.string().trim().nullable().default(null),
  dailyGoal: z.number().positive('Günlük hedef 0\'dan büyük olmalıdır.'),
  step: z.number().positive('Artış miktarı 0\'dan büyük olmalıdır.').default(1),
  repeatDays: z
    .array(z.number().int().min(1).max(7))
    .min(1, 'En az 1 tekrar günü seçilmelidir.')
    .refine((days) => new Set(days).size === days.length, 'Tekrar günleri yinelenemez.'),
  reminderTime: z
    .string()
    .regex(timeRegex, 'Hatırlatma saati HH:mm biçiminde olmalıdır.')
    .nullable()
    .default(null),
  archived: z.boolean().default(false),
  createdAt: z.string()
});

export const habitsArraySchema = z.array(habitSchema);

export type Habit = z.infer<typeof habitSchema>;

export const createHabitInputSchema = z.object({
  name: z.string().trim().min(1, 'Alışkanlık adı boş olamaz.'),
  icon: z.string().trim().min(1, 'İkon adı boş olamaz.'),
  category: habitCategorySchema,
  unit: z.string().trim().nullable().optional(),
  dailyGoal: z.number().positive('Günlük hedef 0\'dan büyük olmalıdır.'),
  step: z.number().positive('Artış miktarı 0\'dan büyük olmalıdır.').optional().default(1),
  repeatDays: z
    .array(z.number().int().min(1).max(7))
    .min(1, 'En az 1 tekrar günü seçilmelidir.')
    .refine((days) => new Set(days).size === days.length, 'Tekrar günleri yinelenemez.'),
  reminderTime: z
    .string()
    .regex(timeRegex, 'Hatırlatma saati HH:mm biçiminde olmalıdır.')
    .nullable()
    .optional()
});

export type CreateHabitInput = z.infer<typeof createHabitInputSchema>;

export const updateHabitInputSchema = z.object({
  name: z.string().trim().min(1, 'Alışkanlık adı boş olamaz.').optional(),
  icon: z.string().trim().min(1, 'İkon adı boş olamaz.').optional(),
  category: habitCategorySchema.optional(),
  unit: z.string().trim().nullable().optional(),
  dailyGoal: z.number().positive('Günlük hedef 0\'dan büyük olmalıdır.').optional(),
  step: z.number().positive('Artış miktarı 0\'dan büyük olmalıdır.').optional(),
  repeatDays: z
    .array(z.number().int().min(1).max(7))
    .min(1, 'En az 1 tekrar günü seçilmelidir.')
    .refine((days) => new Set(days).size === days.length, 'Tekrar günleri yinelenemez.')
    .optional(),
  reminderTime: z
    .string()
    .regex(timeRegex, 'Hatırlatma saati HH:mm biçiminde olmalıdır.')
    .nullable()
    .optional(),
  archived: z.boolean().optional()
});

export type UpdateHabitInput = z.infer<typeof updateHabitInputSchema>;

export interface HabitTemplate {
  id: string;
  name: string;
  icon: string;
  category: HabitCategory;
  unit: string | null;
  dailyGoal: number;
  step: number;
  repeatDays: number[];
  reminderTime: string | null;
  description: string;
}

export const HABIT_TEMPLATES: readonly HabitTemplate[] = [
  {
    id: 'tmpl_water',
    name: 'Su İçme',
    icon: 'water_drop',
    category: 'water',
    unit: 'ml',
    dailyGoal: 2500,
    step: 250,
    repeatDays: [1, 2, 3, 4, 5, 6, 7],
    reminderTime: '10:00',
    description: 'Günlük hidrasyon hedefini koru ve zinde kal.'
  },
  {
    id: 'tmpl_book',
    name: 'Kitap Okuma',
    icon: 'menu_book',
    category: 'book',
    unit: 'sayfa',
    dailyGoal: 20,
    step: 5,
    repeatDays: [1, 2, 3, 4, 5, 6, 7],
    reminderTime: '21:00',
    description: 'Zihnini besle, her gün en az 20 sayfa oku.'
  },
  {
    id: 'tmpl_running',
    name: 'Günlük Koşu',
    icon: 'directions_run',
    category: 'sport',
    unit: 'km',
    dailyGoal: 5,
    step: 1,
    repeatDays: [1, 3, 5, 6],
    reminderTime: '07:30',
    description: 'Kardiyo dayanıklılığını artır ve enerji depola.'
  },
  {
    id: 'tmpl_early_sleep',
    name: 'Erken Uyuma',
    icon: 'bedtime',
    category: 'mind',
    unit: null,
    dailyGoal: 1,
    step: 1,
    repeatDays: [1, 2, 3, 4, 5, 6, 7],
    reminderTime: '22:30',
    description: 'Sirkadiyen ritmini düzenle, kaliteli bir uyku çek.'
  },
  {
    id: 'tmpl_meditation',
    name: 'Meditasyon',
    icon: 'self_improvement',
    category: 'mind',
    unit: 'dk',
    dailyGoal: 15,
    step: 5,
    repeatDays: [1, 2, 3, 4, 5, 6, 7],
    reminderTime: '08:00',
    description: 'Nefes egzersizleriyle iç huzurunu ve odağını bul.'
  },
  {
    id: 'tmpl_walking',
    name: 'Adım Hedefi',
    icon: 'directions_walk',
    category: 'sport',
    unit: 'adım',
    dailyGoal: 10000,
    step: 1000,
    repeatDays: [1, 2, 3, 4, 5, 6, 7],
    reminderTime: '18:00',
    description: 'Günde 10.000 adım atarak hareketli kal.'
  }
];
