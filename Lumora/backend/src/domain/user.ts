import { z } from 'zod';

export const userSchema = z.object({
  id: z.string(),
  email: z.string().nullable(),
  passwordHash: z.string().nullable(),
  displayName: z.string(),
  username: z.string().nullable().default(null),
  avatarUrl: z.string().nullable().default(null),
  isGuest: z.boolean().default(false),
  createdAt: z.string(),
  resetCodeHash: z.string().nullable().optional(),
  resetCodeExpiresAt: z.string().nullable().optional()
});

export const usersArraySchema = z.array(userSchema);

export type User = z.infer<typeof userSchema>;

export type SafeUser = Omit<User, 'passwordHash' | 'resetCodeHash' | 'resetCodeExpiresAt'>;

export function toSafeUser(user: User): SafeUser {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const { passwordHash, resetCodeHash, resetCodeExpiresAt, ...safe } = user;
  return safe;
}

const emailSchema = z
  .string()
  .trim()
  .toLowerCase()
  .email('Geçerli bir e-posta adresi giriniz.');

export const registerInputSchema = z.object({
  email: emailSchema,
  password: z.string().min(8, 'Şifre en az 8 karakter olmalıdır.'),
  displayName: z.string().trim().min(1, 'Görünen ad boş bırakılamaz.')
});

export const loginInputSchema = z.object({
  email: emailSchema,
  password: z.string().min(1, 'Şifre boş bırakılamaz.')
});

export const upgradeInputSchema = z.object({
  email: emailSchema,
  password: z.string().min(8, 'Şifre en az 8 karakter olmalıdır.'),
  displayName: z.string().trim().min(1, 'Görünen ad boş bırakılamaz.')
});

export const forgotPasswordInputSchema = z.object({
  email: emailSchema
});

export const resetPasswordInputSchema = z.object({
  email: emailSchema,
  code: z.string().trim().min(1, 'Sıfırlama kodu gereklidir.'),
  newPassword: z.string().min(8, 'Yeni şifre en az 8 karakter olmalıdır.')
});
