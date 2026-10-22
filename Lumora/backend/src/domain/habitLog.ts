import { z } from 'zod';

export const dateRegex = /^\d{4}-\d{2}-\d{2}$/;

export const habitLogSchema = z.object({
  id: z.string(),
  userId: z.string(),
  habitId: z.string(),
  date: z.string().regex(dateRegex, 'Tarih YYYY-MM-DD biçiminde olmalıdır.'),
  amount: z.number().min(0, 'Miktar 0\'dan küçük olamaz.'),
  completed: z.boolean().default(false),
  updatedAt: z.string()
});

export const habitLogsArraySchema = z.array(habitLogSchema);

export type HabitLog = z.infer<typeof habitLogSchema>;

export const putHabitLogInputSchema = z
  .object({
    amount: z.number().min(0, 'Miktar 0\'dan küçük olamaz.').optional(),
    delta: z.number().optional()
  })
  .refine(
    (data) => data.amount !== undefined || data.delta !== undefined,
    'En az bir miktar (amount) veya değişim (delta) değeri belirtilmelidir.'
  );

export type PutHabitLogInput = z.infer<typeof putHabitLogInputSchema>;

export const logDateParamSchema = z.string().regex(dateRegex, 'Tarih YYYY-MM-DD biçiminde olmalıdır.');

export const getLogsQuerySchema = z.object({
  from: z.string().regex(dateRegex, 'from tarihi YYYY-MM-DD biçiminde olmalıdır.').optional(),
  to: z.string().regex(dateRegex, 'to tarihi YYYY-MM-DD biçiminde olmalıdır.').optional()
});

export type GetLogsQuery = z.infer<typeof getLogsQuerySchema>;
