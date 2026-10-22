import { Router } from 'express';
import { HabitController } from '../controllers/habitController.js';
import { HabitService } from '../services/habitService.js';
import { JsonHabitRepository } from '../repositories/habitRepository.js';
import { JsonHabitLogRepository } from '../repositories/habitLogRepository.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

export function createHabitRoutes(customHabitService?: HabitService) {
  const habitService =
    customHabitService ||
    new HabitService(new JsonHabitRepository(), new JsonHabitLogRepository());
  const habitController = new HabitController(habitService);

  // /habits Router
  const habitRouter = Router();
  habitRouter.use(authMiddleware);
  habitRouter.get('/', habitController.listHabits);
  habitRouter.post('/', habitController.createHabit);
  habitRouter.get('/:id', habitController.getHabit);
  habitRouter.patch('/:id', habitController.updateHabit);
  habitRouter.delete('/:id', habitController.archiveHabit);
  habitRouter.put('/:id/logs/:date', habitController.putLog);

  // /logs Router
  const logRouter = Router();
  logRouter.use(authMiddleware);
  logRouter.get('/', habitController.getLogs);

  // /habit-templates Router
  const templateRouter = Router();
  templateRouter.use(authMiddleware);
  templateRouter.get('/', habitController.getTemplates);

  return {
    habitRouter,
    logRouter,
    templateRouter,
    habitService,
    habitController
  };
}

export const defaultHabitRoutes = createHabitRoutes();
export const habitRouter = defaultHabitRoutes.habitRouter;
export const logRouter = defaultHabitRoutes.logRouter;
export const templateRouter = defaultHabitRoutes.templateRouter;
