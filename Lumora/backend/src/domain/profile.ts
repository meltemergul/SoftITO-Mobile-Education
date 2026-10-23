import { z } from 'zod';
import type { SafeUser } from './user.js';

export const updateProfileInputSchema = z.object({
  displayName: z.string().trim().min(1, 'Görünen ad boş olamaz.').optional(),
  username: z.string().trim().min(1, 'Kullanıcı adı boş olamaz.').nullable().optional(),
  avatarUrl: z.string().trim().nullable().optional()
});

export type UpdateProfileInput = z.infer<typeof updateProfileInputSchema>;

export const updateSettingsInputSchema = z.object({
  theme: z.enum(['light', 'dark', 'system']).optional(),
  weekStartsOn: z.number().int().min(1).max(7).optional(),
  timezone: z.string().optional(),
  notifications: z
    .object({
      smart: z.boolean().optional(),
      morningMotivation: z
        .object({
          enabled: z.boolean().optional(),
          time: z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, 'Saat HH:mm biçiminde olmalıdır.').optional()
        })
        .optional(),
      eveningChainCheck: z
        .object({
          enabled: z.boolean().optional(),
          time: z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, 'Saat HH:mm biçiminde olmalıdır.').optional()
        })
        .optional(),
      soundAndHaptics: z.boolean().optional()
    })
    .optional(),
  streakFreezeCount: z.number().int().min(0).optional()
});

export type UpdateSettingsInput = z.infer<typeof updateSettingsInputSchema>;

export interface QuickMetrics {
  bestStreak: number;
  totalGoals: number;
  level: number;
}

export interface ProfileResponse {
  user: SafeUser;
  quickMetrics: QuickMetrics;
}
