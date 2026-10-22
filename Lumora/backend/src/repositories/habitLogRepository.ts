import path from 'node:path';
import crypto from 'node:crypto';
import { JsonStore } from '../storage/jsonStore.js';
import { HabitLog, habitLogsArraySchema } from '../domain/habitLog.js';

export interface HabitLogRepository {
  findByUserAndHabitAndDate(
    userId: string,
    habitId: string,
    date: string
  ): Promise<HabitLog | null>;
  listByUserAndDateRange(
    userId: string,
    from?: string,
    to?: string
  ): Promise<HabitLog[]>;
  listByUserAndHabit(userId: string, habitId: string): Promise<HabitLog[]>;
  upsert(
    userId: string,
    habitId: string,
    date: string,
    amount: number,
    completed: boolean
  ): Promise<HabitLog>;
}

export class JsonHabitLogRepository implements HabitLogRepository {
  private store: JsonStore<HabitLog[]>;

  constructor(customStoreOrPath?: JsonStore<HabitLog[]> | string) {
    if (customStoreOrPath instanceof JsonStore) {
      this.store = customStoreOrPath;
    } else {
      const filePath =
        typeof customStoreOrPath === 'string'
          ? customStoreOrPath
          : path.resolve(process.cwd(), 'data/habit_logs.json');

      this.store = new JsonStore<HabitLog[]>({
        filePath,
        schema: habitLogsArraySchema,
        defaultValue: []
      });
    }
  }

  public async findByUserAndHabitAndDate(
    userId: string,
    habitId: string,
    date: string
  ): Promise<HabitLog | null> {
    const logs = await this.store.read();
    const found = logs.find(
      (l) => l.userId === userId && l.habitId === habitId && l.date === date
    );
    return found ? { ...found } : null;
  }

  public async listByUserAndDateRange(
    userId: string,
    from?: string,
    to?: string
  ): Promise<HabitLog[]> {
    const logs = await this.store.read();
    return logs
      .filter((l) => {
        if (l.userId !== userId) return false;
        if (from && l.date < from) return false;
        if (to && l.date > to) return false;
        return true;
      })
      .sort((a, b) => a.date.localeCompare(b.date))
      .map((l) => ({ ...l }));
  }

  public async listByUserAndHabit(
    userId: string,
    habitId: string
  ): Promise<HabitLog[]> {
    const logs = await this.store.read();
    return logs
      .filter((l) => l.userId === userId && l.habitId === habitId)
      .sort((a, b) => a.date.localeCompare(b.date))
      .map((l) => ({ ...l }));
  }

  public async upsert(
    userId: string,
    habitId: string,
    date: string,
    amount: number,
    completed: boolean
  ): Promise<HabitLog> {
    let resultLog: HabitLog | null = null;
    const nowIso = new Date().toISOString();

    await this.store.update((logs) => {
      const index = logs.findIndex(
        (l) => l.userId === userId && l.habitId === habitId && l.date === date
      );

      if (index !== -1) {
        const existing = logs[index];
        const updated: HabitLog = {
          ...existing,
          amount,
          completed,
          updatedAt: nowIso
        };
        logs[index] = updated;
        resultLog = updated;
      } else {
        const newLog: HabitLog = {
          id: `log_${crypto.randomBytes(4).toString('hex')}`,
          userId,
          habitId,
          date,
          amount,
          completed,
          updatedAt: nowIso
        };
        logs.push(newLog);
        resultLog = newLog;
      }

      return logs;
    });

    if (!resultLog) {
      throw new Error('Log kaydı oluşturulamadı veya güncellenemedi.');
    }

    return resultLog;
  }
}
