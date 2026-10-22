import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const envSchema = z.object({
  PORT: z.coerce.number().default(3000),
  JWT_SECRET: z.string().min(8, 'JWT_SECRET must be at least 8 characters long'),
  HF_TOKEN: z.string().default('placeholder_hf_token'),
  HF_MODEL: z.string().default('google/gemma-2-9b-it'),
  HF_TIMEOUT_MS: z.coerce.number().default(8000),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development')
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('Environment variable validation error:', parsed.error.format());
  throw new Error('Invalid environment configuration');
}

export const config = parsed.data;
