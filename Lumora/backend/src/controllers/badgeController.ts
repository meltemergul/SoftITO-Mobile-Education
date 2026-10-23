import { Request, Response, NextFunction } from 'express';
import { BadgeService } from '../services/badgeService.js';

export class BadgeController {
  constructor(private badgeService: BadgeService) {}

  public getBadges = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
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

      const result = await this.badgeService.getBadges(userId);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  public getLevel = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
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

      const result = await this.badgeService.getLevel(userId);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };
}
