import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config/index.js';
import { AppError } from './errorHandler.js';

export interface AuthUserPayload {
  id: string;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthUserPayload;
    }
  }
}

export function authMiddleware(req: Request, _res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new AppError('Yetkilendirme başlığı eksik veya geçersiz.', 401, 'UNAUTHORIZED'));
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, config.JWT_SECRET) as { userId: string };
    req.user = { id: decoded.userId };
    return next();
  } catch {
    return next(new AppError('Geçersiz veya süresi dolmuş oturum anahtarı.', 401, 'UNAUTHORIZED'));
  }
}
