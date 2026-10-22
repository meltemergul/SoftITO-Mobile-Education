import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/authService.js';
import {
  registerInputSchema,
  loginInputSchema,
  upgradeInputSchema,
  forgotPasswordInputSchema,
  resetPasswordInputSchema
} from '../domain/user.js';
import { AppError } from '../middleware/errorHandler.js';

export class AuthController {
  constructor(private authService: AuthService) {}

  public register = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const parsed = registerInputSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new AppError(parsed.error.errors[0]?.message || 'Geçersiz veri.', 400, 'VALIDATION_ERROR');
      }
      const result = await this.authService.register(parsed.data);
      res.status(201).json(result);
    } catch (err) {
      next(err);
    }
  };

  public login = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const parsed = loginInputSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new AppError(parsed.error.errors[0]?.message || 'Geçersiz veri.', 400, 'VALIDATION_ERROR');
      }
      const result = await this.authService.login(parsed.data);
      res.status(200).json(result);
    } catch (err) {
      next(err);
    }
  };

  public guest = async (_req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await this.authService.createGuest();
      res.status(201).json(result);
    } catch (err) {
      next(err);
    }
  };

  public upgrade = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user?.id) {
        throw new AppError('Yetkisiz işlem.', 401, 'UNAUTHORIZED');
      }
      const parsed = upgradeInputSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new AppError(parsed.error.errors[0]?.message || 'Geçersiz veri.', 400, 'VALIDATION_ERROR');
      }
      const result = await this.authService.upgradeGuest(req.user.id, parsed.data);
      res.status(200).json(result);
    } catch (err) {
      next(err);
    }
  };

  public forgotPassword = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const parsed = forgotPasswordInputSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new AppError(parsed.error.errors[0]?.message || 'Geçersiz veri.', 400, 'VALIDATION_ERROR');
      }
      const result = await this.authService.forgotPassword(parsed.data);
      res.status(200).json(result);
    } catch (err) {
      next(err);
    }
  };

  public resetPassword = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const parsed = resetPasswordInputSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new AppError(parsed.error.errors[0]?.message || 'Geçersiz veri.', 400, 'VALIDATION_ERROR');
      }
      const result = await this.authService.resetPassword(parsed.data);
      res.status(200).json(result);
    } catch (err) {
      next(err);
    }
  };
}
