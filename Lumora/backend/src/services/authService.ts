import crypto from 'node:crypto';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { config } from '../config/index.js';
import { AppError } from '../middleware/errorHandler.js';
import { UserRepository } from '../repositories/userRepository.js';
import { SafeUser, toSafeUser, User } from '../domain/user.js';

const BCRYPT_ROUNDS = 12;
const JWT_EXPIRES_IN = '7d';

export class AuthService {
  constructor(private userRepository: UserRepository) {}

  private generateToken(userId: string): string {
    return jwt.sign({ userId }, config.JWT_SECRET, {
      expiresIn: JWT_EXPIRES_IN
    });
  }

  public async register(input: {
    email: string;
    password: string;
    displayName: string;
  }): Promise<{ token: string; user: SafeUser }> {
    const normalizedEmail = input.email.trim().toLowerCase();

    const existingUser = await this.userRepository.findByEmail(normalizedEmail);
    if (existingUser) {
      throw new AppError('Bu e-posta adresi zaten kullanımda.', 409, 'EMAIL_EXISTS');
    }

    const passwordHash = await bcrypt.hash(input.password, BCRYPT_ROUNDS);
    const userId = `usr_${crypto.randomBytes(4).toString('hex')}`;

    const newUser: User = {
      id: userId,
      email: normalizedEmail,
      passwordHash,
      displayName: input.displayName.trim(),
      username: normalizedEmail.split('@')[0],
      avatarUrl: null,
      isGuest: false,
      createdAt: new Date().toISOString()
    };

    const savedUser = await this.userRepository.create(newUser);
    const token = this.generateToken(savedUser.id);

    return {
      token,
      user: toSafeUser(savedUser)
    };
  }

  public async login(input: {
    email: string;
    password: string;
  }): Promise<{ token: string; user: SafeUser }> {
    const normalizedEmail = input.email.trim().toLowerCase();

    const user = await this.userRepository.findByEmail(normalizedEmail);
    // Yanlış e-posta ve yanlış şifre aynı hata mesajını vermelidir
    if (!user || user.isGuest || !user.passwordHash) {
      throw new AppError('Geçersiz e-posta veya şifre.', 401, 'INVALID_CREDENTIALS');
    }

    const isMatch = await bcrypt.compare(input.password, user.passwordHash);
    if (!isMatch) {
      throw new AppError('Geçersiz e-posta veya şifre.', 401, 'INVALID_CREDENTIALS');
    }

    const token = this.generateToken(user.id);

    return {
      token,
      user: toSafeUser(user)
    };
  }

  public async createGuest(): Promise<{ token: string; user: SafeUser }> {
    const userId = `usr_${crypto.randomBytes(4).toString('hex')}`;

    const guestUser: User = {
      id: userId,
      email: null,
      passwordHash: null,
      displayName: 'Misafir Kullanıcı',
      username: null,
      avatarUrl: null,
      isGuest: true,
      createdAt: new Date().toISOString()
    };

    const savedUser = await this.userRepository.create(guestUser);
    const token = this.generateToken(savedUser.id);

    return {
      token,
      user: toSafeUser(savedUser)
    };
  }

  public async upgradeGuest(
    guestUserId: string,
    input: {
      email: string;
      password: string;
      displayName: string;
    }
  ): Promise<{ token: string; user: SafeUser }> {
    const guestUser = await this.userRepository.findById(guestUserId);
    if (!guestUser) {
      throw new AppError('Kullanıcı bulunamadı.', 404, 'NOT_FOUND');
    }

    if (!guestUser.isGuest) {
      throw new AppError('Bu hesap zaten kayıtlı bir kullanıcı hesabıdır.', 400, 'ALREADY_REGISTERED');
    }

    const normalizedEmail = input.email.trim().toLowerCase();
    const existing = await this.userRepository.findByEmail(normalizedEmail);
    if (existing && existing.id !== guestUserId) {
      throw new AppError('Bu e-posta adresi zaten kullanımda.', 409, 'EMAIL_EXISTS');
    }

    const passwordHash = await bcrypt.hash(input.password, BCRYPT_ROUNDS);

    const updatedUser = await this.userRepository.update(guestUserId, {
      email: normalizedEmail,
      passwordHash,
      displayName: input.displayName.trim(),
      username: normalizedEmail.split('@')[0],
      isGuest: false
    });

    const token = this.generateToken(updatedUser.id);

    return {
      token,
      user: toSafeUser(updatedUser)
    };
  }

  public async forgotPassword(input: { email: string }): Promise<{ message: string }> {
    const normalizedEmail = input.email.trim().toLowerCase();
    const user = await this.userRepository.findByEmail(normalizedEmail);

    // Güvenlik gereği e-postanın kayıtlı olup olmadığı dışarıya belli edilmez
    if (!user || user.isGuest) {
      return {
        message: 'Şifre sıfırlama talimatları e-posta adresinize gönderildi.'
      };
    }

    // 6 haneli tek kullanımlık sıfırlama kodu
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    const resetCodeHash = await bcrypt.hash(resetCode, 10);
    const resetCodeExpiresAt = new Date(Date.now() + 30 * 60 * 1000).toISOString(); // 30 dakika

    await this.userRepository.update(user.id, {
      resetCodeHash,
      resetCodeExpiresAt
    });

    // E-posta servisi olmadığı için yalnızca geliştirme ortamında sunucu loguna yazılır.
    // Şifre, token ve e-posta ASLA loglanmaz; yalnızca kod ve kullanıcı ID yazılır.
    if (process.env.NODE_ENV !== 'production') {
      console.log(`[AUTH LOG] Şifre sıfırlama kodu üretildi: ${resetCode} (Kullanıcı ID: ${user.id})`);
    }

    return {
      message: 'Şifre sıfırlama talimatları e-posta adresinize gönderildi.'
    };
  }

  public async resetPassword(input: {
    email: string;
    code: string;
    newPassword: string;
  }): Promise<{ message: string }> {
    const normalizedEmail = input.email.trim().toLowerCase();
    const user = await this.userRepository.findByEmail(normalizedEmail);

    if (!user || !user.resetCodeHash || !user.resetCodeExpiresAt) {
      throw new AppError('Geçersiz veya süresi dolmuş sıfırlama kodu.', 400, 'INVALID_RESET_CODE');
    }

    const now = Date.now();
    const expiresAt = new Date(user.resetCodeExpiresAt).getTime();
    if (now > expiresAt) {
      throw new AppError('Sıfırlama kodunun süresi dolmuş.', 400, 'RESET_CODE_EXPIRED');
    }

    const isMatch = await bcrypt.compare(input.code, user.resetCodeHash);
    if (!isMatch) {
      throw new AppError('Geçersiz veya süresi dolmuş sıfırlama kodu.', 400, 'INVALID_RESET_CODE');
    }

    const newPasswordHash = await bcrypt.hash(input.newPassword, BCRYPT_ROUNDS);

    // Şifreyi güncelle ve kodu sıfırla (tek kullanımlık kuralı)
    await this.userRepository.update(user.id, {
      passwordHash: newPasswordHash,
      resetCodeHash: null,
      resetCodeExpiresAt: null
    });

    return {
      message: 'Şifreniz başarıyla sıfırlandı. Yeni şifrenizle giriş yapabilirsiniz.'
    };
  }
}
