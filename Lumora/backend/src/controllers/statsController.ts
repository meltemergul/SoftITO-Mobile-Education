import { Request, Response, NextFunction } from 'express';
import { StatsService } from '../services/statsService.js';

export class StatsController {
  constructor(private statsService: StatsService) {}

  public getStats = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
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

      const range = typeof req.query.range === 'string' ? req.query.range : undefined;
      const result = await this.statsService.getStats(userId, range);

      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };
}
