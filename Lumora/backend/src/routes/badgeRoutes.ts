import { Router } from 'express';
import { BadgeController } from '../controllers/badgeController.js';
import { BadgeService } from '../services/badgeService.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

export function createBadgeRoutes(customBadgeService?: BadgeService) {
  const badgeService = customBadgeService || new BadgeService();
  const badgeController = new BadgeController(badgeService);

  const badgeRouter = Router();
  badgeRouter.use(authMiddleware);
  badgeRouter.get('/', badgeController.getBadges);

  const levelRouter = Router();
  levelRouter.use(authMiddleware);
  levelRouter.get('/', badgeController.getLevel);

  return {
    badgeRouter,
    levelRouter,
    badgeService,
    badgeController
  };
}

export const defaultBadgeRoutes = createBadgeRoutes();
export const badgeRouter = defaultBadgeRoutes.badgeRouter;
export const levelRouter = defaultBadgeRoutes.levelRouter;
