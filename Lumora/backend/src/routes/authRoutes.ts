import { Router } from 'express';
import { AuthController } from '../controllers/authController.js';
import { AuthService } from '../services/authService.js';
import { JsonUserRepository } from '../repositories/userRepository.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { authLimiter } from '../middleware/rateLimiter.js';

export function createAuthRouter(customAuthService?: AuthService): Router {
  const router = Router();
  const authService = customAuthService || new AuthService(new JsonUserRepository());
  const authController = new AuthController(authService);

  router.post('/register', authLimiter, authController.register);
  router.post('/login', authLimiter, authController.login);
  router.post('/guest', authController.guest);
  router.post('/upgrade', authMiddleware, authController.upgrade);
  router.post('/forgot-password', authLimiter, authController.forgotPassword);
  router.post('/reset-password', authLimiter, authController.resetPassword);

  return router;
}

export const authRouter = createAuthRouter();
