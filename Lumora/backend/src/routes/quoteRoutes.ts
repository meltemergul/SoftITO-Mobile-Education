import { Router } from 'express';
import { QuoteController } from '../controllers/quoteController.js';
import { QuoteService } from '../services/quoteService.js';
import { UserSettingsRepository, JsonUserSettingsRepository } from '../repositories/settingsRepository.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

export function createQuoteRoutes(
  customQuoteService?: QuoteService,
  customSettingsRepo?: UserSettingsRepository
) {
  const quoteService = customQuoteService || new QuoteService();
  const settingsRepo = customSettingsRepo || new JsonUserSettingsRepository();
  const quoteController = new QuoteController(quoteService, settingsRepo);

  const quoteRouter = Router();
  quoteRouter.use(authMiddleware);

  quoteRouter.get('/daily', quoteController.getDailyQuote);
  quoteRouter.post('/:id/favorite', quoteController.addFavorite);
  quoteRouter.delete('/:id/favorite', quoteController.removeFavorite);

  return {
    quoteRouter,
    quoteService,
    quoteController
  };
}

export const defaultQuoteRoutes = createQuoteRoutes();
export const quoteRouter = defaultQuoteRoutes.quoteRouter;
