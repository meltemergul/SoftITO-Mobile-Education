import { z } from 'zod';

export const quoteSchema = z.object({
  id: z.string().min(1),
  text: z.string().min(1),
  author: z.string().nullable(),
  source: z.enum(['fallback', 'ai'])
});

export type Quote = z.infer<typeof quoteSchema>;

export const dailyQuoteDtoSchema = quoteSchema.extend({
  isFavorite: z.boolean()
});

export type DailyQuoteDto = z.infer<typeof dailyQuoteDtoSchema>;

export const favoriteRecordSchema = z.object({
  userId: z.string().min(1),
  quoteId: z.string().min(1),
  createdAt: z.string().datetime()
});

export type FavoriteRecord = z.infer<typeof favoriteRecordSchema>;

export const quotesCacheSchema = z.object({
  generatedAt: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).or(z.literal('')),
  language: z.string().default('tr'),
  quotes: z.array(quoteSchema)
});

export type QuotesCache = z.infer<typeof quotesCacheSchema>;
