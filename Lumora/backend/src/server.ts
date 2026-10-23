import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { config } from './config/index.js';
import { standardLimiter } from './middleware/rateLimiter.js';
import { errorHandler } from './middleware/errorHandler.js';
import { authRouter } from './routes/authRoutes.js';
import {
  habitRouter,
  logRouter,
  templateRouter
} from './routes/habitRoutes.js';
import { todayRouter } from './routes/todayRoutes.js';
import { quoteRouter } from './routes/quoteRoutes.js';
import { calendarRouter } from './routes/calendarRoutes.js';
import { statsRouter } from './routes/statsRoutes.js';
import { badgeRouter, levelRouter } from './routes/badgeRoutes.js';
import {
  profileRouter,
  settingsRouter,
  exportRouter,
  accountRouter
} from './routes/profileRoutes.js';

export const app = express();

// Security and utility middlewares
app.use(helmet());

const defaultAllowedOrigins = [
  'http://localhost:3000',
  'http://localhost:5173',
  'http://127.0.0.1:3000',
  'http://localhost:8080'
];

const configuredOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map((o) => o.trim())
  : defaultAllowedOrigins;

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile applications, native apps, curl, tests)
      if (!origin) return callback(null, true);
      if (
        configuredOrigins.includes(origin) ||
        process.env.NODE_ENV !== 'production'
      ) {
        return callback(null, true);
      }
      return callback(new Error('CORS: Bu kaynağa erişim yetkisi yok.'));
    },
    credentials: true
  })
);

app.use(express.json());
app.use(standardLimiter);

// Health check endpoint
app.get('/health', (_req: Request, res: Response) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString()
  });
});

// Routes
app.use('/auth', authRouter);
app.use('/habits', habitRouter);
app.use('/logs', logRouter);
app.use('/habit-templates', templateRouter);
app.use('/today', todayRouter);
app.use('/quotes', quoteRouter);
app.use('/calendar', calendarRouter);
app.use('/stats', statsRouter);
app.use('/badges', badgeRouter);
app.use('/level', levelRouter);
app.use('/profile', profileRouter);
app.use('/settings', settingsRouter);
app.use('/export', exportRouter);
app.use('/account', accountRouter);

// Fallback 404 handler
app.use((_req: Request, res: Response) => {
  res.status(404).json({
    error: {
      code: 'NOT_FOUND',
      message: 'İstenen kaynak bulunamadı.'
    }
  });
});

// Global error handler
app.use(errorHandler);

if (process.env.NODE_ENV !== 'test') {
  app.listen(config.PORT, () => {
    console.log(`[Lumora Backend] Server running on port ${config.PORT}`);
  });
}
