import { Router } from 'express';
import { ProfileController } from '../controllers/profileController.js';
import { ProfileService } from '../services/profileService.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

export function createProfileRoutes(customProfileService?: ProfileService) {
  const profileService = customProfileService || new ProfileService();
  const profileController = new ProfileController(profileService);

  const profileRouter = Router();
  profileRouter.use(authMiddleware);
  profileRouter.get('/', profileController.getProfile);
  profileRouter.patch('/', profileController.updateProfile);

  const settingsRouter = Router();
  settingsRouter.use(authMiddleware);
  settingsRouter.get('/', profileController.getSettings);
  settingsRouter.patch('/', profileController.updateSettings);

  const exportRouter = Router();
  exportRouter.use(authMiddleware);
  exportRouter.get('/', profileController.exportData);

  const accountRouter = Router();
  accountRouter.use(authMiddleware);
  accountRouter.delete('/', profileController.deleteAccount);

  return {
    profileRouter,
    settingsRouter,
    exportRouter,
    accountRouter,
    profileService,
    profileController
  };
}

export const defaultProfileRoutes = createProfileRoutes();
export const profileRouter = defaultProfileRoutes.profileRouter;
export const settingsRouter = defaultProfileRoutes.settingsRouter;
export const exportRouter = defaultProfileRoutes.exportRouter;
export const accountRouter = defaultProfileRoutes.accountRouter;
