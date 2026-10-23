import { z } from 'zod';

export const badgeCategorySchema = z.enum(['streak', 'sport', 'mind']);
export type BadgeCategory = z.infer<typeof badgeCategorySchema>;

export const badgeItemSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string(),
  category: badgeCategorySchema,
  icon: z.string(),
  xpReward: z.number().int().nonnegative(),
  targetValue: z.number().positive(),
  unit: z.string(),
  isUnlocked: z.boolean(),
  unlockedAt: z.string().nullable(),
  progress: z.number().nonnegative(),
  maxProgress: z.number().positive(),
  progressPercent: z.number().min(0).max(100)
});

export type UserBadge = z.infer<typeof badgeItemSchema>;

export const badgesResponseSchema = z.object({
  badges: z.array(badgeItemSchema),
  unlockedCount: z.number().int().nonnegative(),
  totalCount: z.number().int().positive(),
  newlyUnlockedBadge: badgeItemSchema.nullable().optional()
});

export type BadgesResponse = z.infer<typeof badgesResponseSchema>;
