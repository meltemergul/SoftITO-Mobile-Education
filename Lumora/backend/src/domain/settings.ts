import { z } from 'zod';

export const userSettingsSchema = z.object({
  userId: z.string(),
  theme: z.enum(['light', 'dark', 'system']).default('system'),
  weekStartsOn: z.number().int().min(1).max(7).default(1),
  timezone: z.string().default('Europe/Istanbul'),
  notifications: z
    .object({
      smart: z.boolean().default(true),
      morningMotivation: z
        .object({
          enabled: z.boolean().default(true),
          time: z.string().default('08:00')
        })
        .default({ enabled: true, time: '08:00' }),
      eveningChainCheck: z
        .object({
          enabled: z.boolean().default(true),
          time: z.string().default('21:30')
        })
        .default({ enabled: true, time: '21:30' }),
      soundAndHaptics: z.boolean().default(true)
    })
    .default({
      smart: true,
      morningMotivation: { enabled: true, time: '08:00' },
      eveningChainCheck: { enabled: true, time: '21:30' },
      soundAndHaptics: true
    }),
  streakFreezeCount: z.number().int().min(0).default(2)
});

export const userSettingsArraySchema = z.array(userSettingsSchema);

export type UserSettings = z.infer<typeof userSettingsSchema>;

export function createDefaultSettings(userId: string): UserSettings {
  return {
    userId,
    theme: 'system',
    weekStartsOn: 1,
    timezone: 'Europe/Istanbul',
    notifications: {
      smart: true,
      morningMotivation: { enabled: true, time: '08:00' },
      eveningChainCheck: { enabled: true, time: '21:30' },
      soundAndHaptics: true
    },
    streakFreezeCount: 2
  };
}
