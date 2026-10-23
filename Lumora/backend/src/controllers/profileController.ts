import { Request, Response, NextFunction } from 'express';
import { ProfileService } from '../services/profileService.js';

export class ProfileController {
  constructor(private profileService: ProfileService) {}

  public getProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = (req as any).user?.id;
      if (!userId) {
        res.status(401).json({
          error: { code: 'UNAUTHORIZED', message: 'Oturum açılması gerekiyor.' }
        });
        return;
      }

      const result = await this.profileService.getProfile(userId);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  public updateProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = (req as any).user?.id;
      if (!userId) {
        res.status(401).json({
          error: { code: 'UNAUTHORIZED', message: 'Oturum açılması gerekiyor.' }
        });
        return;
      }

      const result = await this.profileService.updateProfile(userId, req.body);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  public getSettings = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = (req as any).user?.id;
      if (!userId) {
        res.status(401).json({
          error: { code: 'UNAUTHORIZED', message: 'Oturum açılması gerekiyor.' }
        });
        return;
      }

      const result = await this.profileService.getSettings(userId);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  public updateSettings = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = (req as any).user?.id;
      if (!userId) {
        res.status(401).json({
          error: { code: 'UNAUTHORIZED', message: 'Oturum açılması gerekiyor.' }
        });
        return;
      }

      const result = await this.profileService.updateSettings(userId, req.body);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  public exportData = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = (req as any).user?.id;
      if (!userId) {
        res.status(401).json({
          error: { code: 'UNAUTHORIZED', message: 'Oturum açılması gerekiyor.' }
        });
        return;
      }

      const format = req.query.format === 'csv' ? 'csv' : 'json';
      const result = await this.profileService.exportData(userId, format);

      res.setHeader('Content-Type', result.contentType);
      res.setHeader('Content-Disposition', `attachment; filename="${result.filename}"`);

      if (format === 'csv') {
        res.status(200).send(result.data);
      } else {
        res.status(200).json(result.data);
      }
    } catch (error) {
      next(error);
    }
  };

  public deleteAccount = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = (req as any).user?.id;
      if (!userId) {
        res.status(401).json({
          error: { code: 'UNAUTHORIZED', message: 'Oturum açılması gerekiyor.' }
        });
        return;
      }

      await this.profileService.deleteAccount(userId);
      res.status(200).json({
        success: true,
        message: 'Hesap ve tüm veriler kalıcı olarak silindi.'
      });
    } catch (error) {
      next(error);
    }
  };
}
