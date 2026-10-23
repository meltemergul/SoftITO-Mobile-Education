import { Request, Response, NextFunction } from 'express';
import { CalendarService } from '../services/calendarService.js';

export class CalendarController {
  constructor(private calendarService: CalendarService) {}

  public getMonthCalendar = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
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

      const month = typeof req.query.month === 'string' ? req.query.month : undefined;
      const result = await this.calendarService.getMonthCalendar(userId, month);

      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  public getDayDetail = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = (req as any).user?.id;
      const date = req.params.date;

      if (!userId) {
        res.status(401).json({
          error: {
            code: 'UNAUTHORIZED',
            message: 'Oturum açılması gerekiyor.'
          }
        });
        return;
      }

      if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
        res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Tarih YYYY-MM-DD biçiminde olmalıdır.'
          }
        });
        return;
      }

      const result = await this.calendarService.getDayDetail(userId, date);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };
}
