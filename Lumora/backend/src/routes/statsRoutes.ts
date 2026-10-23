import { Router } from 'express';
import { StatsController } from '../controllers/statsController.js';
import { StatsService } from '../services/statsService.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

export function createStatsRoutes(customStatsService?: StatsService) {
  const statsService = customStatsService || new StatsService();
  const statsController = new StatsController(statsService);

  const statsRouter = Router();
  statsRouter.use(authMiddleware);

  statsRouter.get('/', statsController.getStats);

  return {
    statsRouter,
    statsService,
    statsController
  };
}

export const defaultStatsRoutes = createStatsRoutes();
export const statsRouter = defaultStatsRoutes.statsRouter;
