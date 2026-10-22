import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import express from 'express';
import request from 'supertest';
import path from 'node:path';
import fs from 'node:fs';
import bcrypt from 'bcrypt';
import { JsonStore } from '../storage/jsonStore.js';
import { usersArraySchema, User } from '../domain/user.js';
import { JsonUserRepository } from '../repositories/userRepository.js';
import { AuthService } from '../services/authService.js';
import { createAuthRouter } from './authRoutes.js';
import { errorHandler } from '../middleware/errorHandler.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

describe('Auth Entegrasyon Testleri', () => {
  const testDir = path.resolve(__dirname, '../../test_tmp_auth');
  const testUsersFile = path.join(testDir, 'users.json');

  let app: express.Express;
  let repo: JsonUserRepository;
  let authService: AuthService;

  beforeEach(async () => {
    await fs.promises.rm(testDir, { recursive: true, force: true });
    await fs.promises.mkdir(testDir, { recursive: true });

    const store = new JsonStore<User[]>({
      filePath: testUsersFile,
      schema: usersArraySchema,
      defaultValue: []
    });

    repo = new JsonUserRepository(store);
    authService = new AuthService(repo);

    app = express();
    app.use(express.json());
    app.use('/auth', createAuthRouter(authService));

    // Test protected endpoint for authMiddleware verification
    app.get('/test-protected', authMiddleware, (req, res) => {
      res.json({ success: true, userId: req.user?.id });
    });

    app.use(errorHandler);
  });

  afterEach(async () => {
    vi.restoreAllMocks();
    await fs.promises.rm(testDir, { recursive: true, force: true });
  });

  it('1. Kayıt (register): Yeni kullanıcı başarıyla kaydedilmeli, bcrypt(12) ve JWT dönmeli', async () => {
    const res = await request(app)
      .post('/auth/register')
      .send({
        email: 'Selin@Example.Com ', // büyük harf ve boşluklu
        password: 'Password123!',
        displayName: 'Selin Yılmaz'
      });

    expect(res.status).toBe(201);
    expect(res.body.token).toBeDefined();
    expect(res.body.user).toBeDefined();
    expect(res.body.user.email).toBe('selin@example.com'); // küçük harfe çevrilmiş
    expect(res.body.user.displayName).toBe('Selin Yılmaz');
    expect(res.body.user.isGuest).toBe(false);

    // Güvenlik: şifre hash'i veya sıfırlama bilgileri istemciye dönmemeli
    expect(res.body.user.passwordHash).toBeUndefined();
    expect(res.body.user.resetCodeHash).toBeUndefined();

    // Veritabanındaki kaydı doğrula (bcrypt maliyeti 12 olmalı: $2b$12$)
    const stored = await repo.findByEmail('selin@example.com');
    expect(stored).not.toBeNull();
    expect(stored?.passwordHash).toMatch(/^\$2[aby]\$12\$/);

    // 8 karakterden kısa şifre reddedilmeli
    const shortPassRes = await request(app)
      .post('/auth/register')
      .send({
        email: 'kisa@example.com',
        password: 'short',
        displayName: 'Kısa Şifre'
      });
    expect(shortPassRes.status).toBe(400);
    expect(shortPassRes.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('2. Giriş (login): Doğru şifre ile başarılı giriş yapılmalı (büyük/küçük harf duyarsız)', async () => {
    await request(app)
      .post('/auth/register')
      .send({
        email: 'selin@example.com',
        password: 'Password123!',
        displayName: 'Selin Yılmaz'
      });

    const res = await request(app)
      .post('/auth/login')
      .send({
        email: 'SELIN@EXAMPLE.COM',
        password: 'Password123!'
      });

    expect(res.status).toBe(200);
    expect(res.body.token).toBeDefined();
    expect(res.body.user.email).toBe('selin@example.com');
  });

  it('3. Yanlış şifre ve yanlış e-posta aynı hata mesajını vermeli', async () => {
    await request(app)
      .post('/auth/register')
      .send({
        email: 'selin@example.com',
        password: 'Password123!',
        displayName: 'Selin Yılmaz'
      });

    // Yanlış şifre
    const wrongPassRes = await request(app)
      .post('/auth/login')
      .send({
        email: 'selin@example.com',
        password: 'YanlisSifre123!'
      });

    // Kayıtlı olmayan e-posta
    const wrongEmailRes = await request(app)
      .post('/auth/login')
      .send({
        email: 'kayitsiz@example.com',
        password: 'Password123!'
      });

    expect(wrongPassRes.status).toBe(401);
    expect(wrongEmailRes.status).toBe(401);
    expect(wrongPassRes.body).toEqual({
      error: {
        code: 'INVALID_CREDENTIALS',
        message: 'Geçersiz e-posta veya şifre.'
      }
    });
    expect(wrongEmailRes.body).toEqual(wrongPassRes.body);
  });

  it('4. Aynı e-posta ile ikinci kayıt reddedilmeli (409 Conflict)', async () => {
    await request(app)
      .post('/auth/register')
      .send({
        email: 'selin@example.com',
        password: 'Password123!',
        displayName: 'Selin Yılmaz'
      });

    const duplicateRes = await request(app)
      .post('/auth/register')
      .send({
        email: 'SELIN@EXAMPLE.COM',
        password: 'AnotherPassword123!',
        displayName: 'İkinci Selin'
      });

    expect(duplicateRes.status).toBe(409);
    expect(duplicateRes.body.error.code).toBe('EMAIL_EXISTS');
  });

  it('5. Misafir oluşturma ve hesaba dönüştürme (upgrade): Aynı ID korunmalı', async () => {
    // Misafir kullanıcı oluştur
    const guestRes = await request(app).post('/auth/guest');
    expect(guestRes.status).toBe(201);
    expect(guestRes.body.user.isGuest).toBe(true);
    expect(guestRes.body.user.email).toBeNull();
    const guestId = guestRes.body.user.id;
    const guestToken = guestRes.body.token;

    // Token olmadan hesaba dönüştürme denenirse 401 dönmeli
    const unauthUpgrade = await request(app)
      .post('/auth/upgrade')
      .send({
        email: 'misafir_kayit@example.com',
        password: 'Password123!',
        displayName: 'Dönüşen Kullanıcı'
      });
    expect(unauthUpgrade.status).toBe(401);

    // Misafir token'ı ile hesaba dönüştür
    const upgradeRes = await request(app)
      .post('/auth/upgrade')
      .set('Authorization', `Bearer ${guestToken}`)
      .send({
        email: 'misafir_kayit@example.com',
        password: 'Password123!',
        displayName: 'Dönüşen Kullanıcı'
      });

    expect(upgradeRes.status).toBe(200);
    expect(upgradeRes.body.user.id).toBe(guestId); // AYNI USER ID KORUNDU
    expect(upgradeRes.body.user.isGuest).toBe(false);
    expect(upgradeRes.body.user.email).toBe('misafir_kayit@example.com');

    // Artık yeni hesap bilgileriyle giriş yapılabilmeli
    const loginRes = await request(app)
      .post('/auth/login')
      .send({
        email: 'misafir_kayit@example.com',
        password: 'Password123!'
      });
    expect(loginRes.status).toBe(200);
    expect(loginRes.body.user.id).toBe(guestId);
  });

  it('6. Şifre sıfırlama akışı: forgot-password kayıt durumunu gizlemeli ve kod ile şifre değişmeli', async () => {
    await request(app)
      .post('/auth/register')
      .send({
        email: 'selin@example.com',
        password: 'OldPassword123!',
        displayName: 'Selin Yılmaz'
      });

    // Kayıtlı olmayan e-posta ile forgot-password isteği
    const unregForgotRes = await request(app)
      .post('/auth/forgot-password')
      .send({ email: 'olmayan@example.com' });
    expect(unregForgotRes.status).toBe(200);

    // Kayıtlı e-posta ile forgot-password isteği
    let interceptedCode = '';
    const consoleSpy = vi.spyOn(console, 'log').mockImplementation((msg: string) => {
      const match = msg.match(/Şifre sıfırlama kodu üretildi: (\d{6})/);
      if (match) {
        interceptedCode = match[1];
      }
    });

    const regForgotRes = await request(app)
      .post('/auth/forgot-password')
      .send({ email: 'selin@example.com' });

    expect(regForgotRes.status).toBe(200);
    expect(regForgotRes.body).toEqual(unregForgotRes.body); // Yanıtlar birebir aynı, bilgi sızdırmaz
    expect(interceptedCode).toHaveLength(6);

    // Doğru kod ve yeni şifre ile reset-password
    const resetRes = await request(app)
      .post('/auth/reset-password')
      .send({
        email: 'selin@example.com',
        code: interceptedCode,
        newPassword: 'BrandNewPassword123!'
      });

    expect(resetRes.status).toBe(200);

    // Eski şifreyle giriş başarısız olmalı
    const oldLogin = await request(app)
      .post('/auth/login')
      .send({
        email: 'selin@example.com',
        password: 'OldPassword123!'
      });
    expect(oldLogin.status).toBe(401);

    // Yeni şifreyle giriş başarılı olmalı
    const newLogin = await request(app)
      .post('/auth/login')
      .send({
        email: 'selin@example.com',
        password: 'BrandNewPassword123!'
      });
    expect(newLogin.status).toBe(200);

    // Aynı kodun ikinci kez kullanımı reddedilmeli (tek kullanımlık)
    const reuseRes = await request(app)
      .post('/auth/reset-password')
      .send({
        email: 'selin@example.com',
        code: interceptedCode,
        newPassword: 'AnotherPassword123!'
      });
    expect(reuseRes.status).toBe(400);
    expect(reuseRes.body.error.code).toBe('INVALID_RESET_CODE');

    consoleSpy.mockRestore();
  });

  it('7. Süresi geçmiş sıfırlama kodu reddedilmeli', async () => {
    await request(app)
      .post('/auth/register')
      .send({
        email: 'selin@example.com',
        password: 'Password123!',
        displayName: 'Selin Yılmaz'
      });

    const testCode = '654321';
    const codeHash = await bcrypt.hash(testCode, 10);
    const expiredTime = new Date(Date.now() - 35 * 60 * 1000).toISOString(); // 35 dakika önce (süresi dolmuş)

    const user = await repo.findByEmail('selin@example.com');
    await repo.update(user!.id, {
      resetCodeHash: codeHash,
      resetCodeExpiresAt: expiredTime
    });

    const resetRes = await request(app)
      .post('/auth/reset-password')
      .send({
        email: 'selin@example.com',
        code: testCode,
        newPassword: 'NewPassword123!'
      });

    expect(resetRes.status).toBe(400);
    expect(resetRes.body.error.code).toBe('RESET_CODE_EXPIRED');
  });

  it('8. authMiddleware doğrulaması: Bearer token geçerliliği ve req.user.id', async () => {
    // 1) Token yok
    const noToken = await request(app).get('/test-protected');
    expect(noToken.status).toBe(401);
    expect(noToken.body.error.code).toBe('UNAUTHORIZED');

    // 2) Geçersiz token
    const invalidToken = await request(app)
      .get('/test-protected')
      .set('Authorization', 'Bearer gecersiz_token_degeri');
    expect(invalidToken.status).toBe(401);
    expect(invalidToken.body.error.code).toBe('UNAUTHORIZED');

    // 3) Geçerli kullanıcı token'ı
    const regRes = await request(app)
      .post('/auth/register')
      .send({
        email: 'selin@example.com',
        password: 'Password123!',
        displayName: 'Selin Yılmaz'
      });

    const validToken = regRes.body.token;
    const validRes = await request(app)
      .get('/test-protected')
      .set('Authorization', `Bearer ${validToken}`);

    expect(validRes.status).toBe(200);
    expect(validRes.body.success).toBe(true);
    expect(validRes.body.userId).toBe(regRes.body.user.id);
  });
});
