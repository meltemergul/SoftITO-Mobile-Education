import { Router } from 'express';
import { CalendarController } from '../controllers/calendarController.js';
import { CalendarService } from '../services/calendarService.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

export function createCalendarRoutes(customCalendarService?: CalendarService) {
  const calendarService = customCalendarService || new CalendarService();
  const calendarController = new CalendarController(calendarService);

  const calendarRouter = Router();
  calendarRouter.use(authMiddleware);

  calendarRouter.get('/', calendarController.getMonthCalendar);
  calendarRouter.get('/day/:date', calendarController.getDayDetail);

  return {
    calendarRouter,
    calendarService,
    calendarController
  };
}

export const defaultCalendarRoutes = createCalendarRoutes();
export const calendarRouter = defaultCalendarRoutes.calendarRouter;
