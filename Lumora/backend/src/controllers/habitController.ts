import { Request, Response, NextFunction } from 'express';
import { HabitService } from '../services/habitService.js';
import {
  createHabitInputSchema,
  updateHabitInputSchema
} from '../domain/habit.js';
import {
  getLogsQuerySchema,
  logDateParamSchema,
  putHabitLogInputSchema
} from '../domain/habitLog.js';
import { AppError } from '../middleware/errorHandler.js';

export class HabitController {
  constructor(private habitService: HabitService) {}

  public listHabits = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.id;
      if (!userId) {
        throw new AppError('Yetkisiz işlem.', 401, 'UNAUTHORIZED');
      }

      const includeArchived = req.query.includeArchived === 'true';
      const habits = await this.habitService.listHabits(userId, includeArchived);
      res.status(200).json(habits);
    } catch (err) {
      next(err);
    }
  };

  public getHabit = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.id;
      if (!userId) {
        throw new AppError('Yetkisiz işlem.', 401, 'UNAUTHORIZED');
      }

      const habit = await this.habitService.getHabitById(userId, req.params.id);
      res.status(200).json(habit);
    } catch (err) {
      next(err);
    }
  };

  public createHabit = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.id;
      if (!userId) {
        throw new AppError('Yetkisiz işlem.', 401, 'UNAUTHORIZED');
      }

      const parsed = createHabitInputSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new AppError(
          parsed.error.errors[0]?.message || 'Geçersiz alışkanlık verisi.',
          400,
          'VALIDATION_ERROR'
        );
      }

      const habit = await this.habitService.createHabit(userId, parsed.data);
      res.status(201).json(habit);
    } catch (err) {
      next(err);
    }
  };

  public updateHabit = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.id;
      if (!userId) {
        throw new AppError('Yetkisiz işlem.', 401, 'UNAUTHORIZED');
      }

      const parsed = updateHabitInputSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new AppError(
          parsed.error.errors[0]?.message || 'Geçersiz güncelleme verisi.',
          400,
          'VALIDATION_ERROR'
        );
      }

      const habit = await this.habitService.updateHabit(
        userId,
        req.params.id,
        parsed.data
      );
      res.status(200).json(habit);
    } catch (err) {
      next(err);
    }
  };

  public archiveHabit = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.id;
      if (!userId) {
        throw new AppError('Yetkisiz işlem.', 401, 'UNAUTHORIZED');
      }

      await this.habitService.archiveHabit(userId, req.params.id);
      res.status(200).json({
        message: 'Alışkanlık başarıyla arşivlendi.',
        id: req.params.id,
        archived: true
      });
    } catch (err) {
      next(err);
    }
  };

  public getTemplates = async (_req: Request, res: Response, next: NextFunction) => {
    try {
      const templates = this.habitService.getTemplates();
      res.status(200).json(templates);
    } catch (err) {
      next(err);
    }
  };

  public putLog = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.id;
      if (!userId) {
        throw new AppError('Yetkisiz işlem.', 401, 'UNAUTHORIZED');
      }

      const dateParsed = logDateParamSchema.safeParse(req.params.date);
      if (!dateParsed.success) {
        throw new AppError(
          dateParsed.error.errors[0]?.message || 'Geçersiz tarih parametresi.',
          400,
          'VALIDATION_ERROR'
        );
      }

      const bodyParsed = putHabitLogInputSchema.safeParse(req.body);
      if (!bodyParsed.success) {
        throw new AppError(
          bodyParsed.error.errors[0]?.message || 'Geçersiz log verisi.',
          400,
          'VALIDATION_ERROR'
        );
      }

      const log = await this.habitService.putLog(
        userId,
        req.params.id,
        dateParsed.data,
        bodyParsed.data
      );
      res.status(200).json(log);
    } catch (err) {
      next(err);
    }
  };

  public getLogs = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.id;
      if (!userId) {
        throw new AppError('Yetkisiz işlem.', 401, 'UNAUTHORIZED');
      }

      const queryParsed = getLogsQuerySchema.safeParse(req.query);
      if (!queryParsed.success) {
        throw new AppError(
          queryParsed.error.errors[0]?.message || 'Geçersiz tarih aralığı filtresi.',
          400,
          'VALIDATION_ERROR'
        );
      }

      const logs = await this.habitService.getLogs(
        userId,
        queryParsed.data.from,
        queryParsed.data.to
      );
      res.status(200).json(logs);
    } catch (err) {
      next(err);
    }
  };
}
