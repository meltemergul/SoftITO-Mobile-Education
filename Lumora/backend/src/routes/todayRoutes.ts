import { Router, Request, Response, NextFunction } from 'express';
import { TodayService } from '../services/todayService.js';
import { JsonHabitRepository } from '../repositories/habitRepository.js';
import { JsonHabitLogRepository } from '../repositories/habitLogRepository.js';
import { JsonUserSettingsRepository } from '../repositories/settingsRepository.js';
import { authMiddleware } from '../middleware/authMiddleware.js';
import { AppError } from '../middleware/errorHandler.js';

export function createTodayRouter(customService?: TodayService): Router {
  const router = Router();
  const service =
    customService ||
    new TodayService(
      new JsonHabitRepository(),
      new JsonHabitLogRepository(),
      new JsonUserSettingsRepository()
    );

  router.use(authMiddleware);

  router.get('/', async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.id;
      if (!userId) {
        throw new AppError('Yetkisiz işlem.', 401, 'UNAUTHORIZED');
      }

      const todayData = await service.getToday(userId);
      res.status(200).json(todayData);
    } catch (err) {
      next(err);
    }
  });

  return router;
}

export const todayRouter = createTodayRouter();
