import { Request, Response, NextFunction } from 'express';
import { QuoteService } from '../services/quoteService.js';
import { UserSettingsRepository, JsonUserSettingsRepository } from '../repositories/settingsRepository.js';
import { formatDateInTimezone } from '../services/domainRules.js';

export class QuoteController {
  constructor(
    private quoteService: QuoteService,
    private settingsRepository: UserSettingsRepository = new JsonUserSettingsRepository()
  ) {}

  public getDailyQuote = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = (req as any).user?.id;
      if (!userId) {
        res.status(401).json({
          error: {
            code: 'UNAUTHORIZED',
            message: 'Oturum açılması gerekiyor.'
          }
        });
        return;
      }

      let dateStr = typeof req.query.date === 'string' ? req.query.date : undefined;

      if (!dateStr) {
        try {
          const settings = await this.settingsRepository.getByUserId(userId);
          dateStr = formatDateInTimezone(new Date(), settings.timezone);
        } catch {
          dateStr = new Date().toISOString().slice(0, 10);
        }
      }

      const quote = await this.quoteService.getDailyQuote(userId, dateStr);

      res.status(200).json({ quote });
    } catch (error) {
      next(error);
    }
  };

  public addFavorite = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = (req as any).user?.id;
      const quoteId = req.params.id;

      if (!userId) {
        res.status(401).json({
          error: {
            code: 'UNAUTHORIZED',
            message: 'Oturum açılması gerekiyor.'
          }
        });
        return;
      }

      if (!quoteId) {
        res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Söz kimliği (id) gereklidir.'
          }
        });
        return;
      }

      await this.quoteService.addFavorite(userId, quoteId);
      res.status(200).json({
        success: true,
        isFavorite: true
      });
    } catch (error) {
      next(error);
    }
  };

  public removeFavorite = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = (req as any).user?.id;
      const quoteId = req.params.id;

      if (!userId) {
        res.status(401).json({
          error: {
            code: 'UNAUTHORIZED',
            message: 'Oturum açılması gerekiyor.'
          }
        });
        return;
      }

      if (!quoteId) {
        res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Söz kimliği (id) gereklidir.'
          }
        });
        return;
      }

      await this.quoteService.removeFavorite(userId, quoteId);
      res.status(200).json({
        success: true,
        isFavorite: false
      });
    } catch (error) {
      next(error);
    }
  };
}
