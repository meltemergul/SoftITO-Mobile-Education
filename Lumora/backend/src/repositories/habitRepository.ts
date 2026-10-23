import path from 'node:path';
import crypto from 'node:crypto';
import { JsonStore } from '../storage/jsonStore.js';
import {
  CreateHabitInput,
  Habit,
  habitsArraySchema,
  UpdateHabitInput
} from '../domain/habit.js';

export interface HabitRepository {
  listByUser(userId: string, includeArchived?: boolean): Promise<Habit[]>;
  getById(userId: string, id: string): Promise<Habit | null>;
  create(userId: string, input: CreateHabitInput): Promise<Habit>;
  update(userId: string, id: string, patch: UpdateHabitInput): Promise<Habit>;
  archive(userId: string, id: string): Promise<void>;
  deleteAllByUser(userId: string): Promise<void>;
}

export class JsonHabitRepository implements HabitRepository {
  private store: JsonStore<Habit[]>;

  constructor(customStoreOrPath?: JsonStore<Habit[]> | string) {
    if (customStoreOrPath instanceof JsonStore) {
      this.store = customStoreOrPath;
    } else {
      const filePath =
        typeof customStoreOrPath === 'string'
          ? customStoreOrPath
          : path.resolve(process.cwd(), 'data/habits.json');

      this.store = new JsonStore<Habit[]>({
        filePath,
        schema: habitsArraySchema,
        defaultValue: []
      });
    }
  }

  public async listByUser(userId: string, includeArchived = false): Promise<Habit[]> {
    const habits = await this.store.read();
    return habits
      .filter((h) => h.userId === userId && (includeArchived ? true : !h.archived))
      .map((h) => ({ ...h }));
  }

  public async getById(userId: string, id: string): Promise<Habit | null> {
    const habits = await this.store.read();
    const found = habits.find((h) => h.id === id && h.userId === userId);
    return found ? { ...found } : null;
  }

  public async create(userId: string, input: CreateHabitInput): Promise<Habit> {
    const newHabit: Habit = {
      id: `hbt_${crypto.randomBytes(4).toString('hex')}`,
      userId,
      name: input.name.trim(),
      icon: input.icon.trim(),
      category: input.category,
      unit: input.unit?.trim() || null,
      dailyGoal: input.dailyGoal,
      step: input.step ?? 1,
      repeatDays: [...input.repeatDays].sort((a, b) => a - b),
      reminderTime: input.reminderTime ?? null,
      archived: false,
      createdAt: new Date().toISOString()
    };

    await this.store.update((habits) => {
      return [...habits, newHabit];
    });

    return { ...newHabit };
  }

  public async update(userId: string, id: string, patch: UpdateHabitInput): Promise<Habit> {
    let updated: Habit | null = null;

    await this.store.update((habits) => {
      const index = habits.findIndex((h) => h.id === id && h.userId === userId);
      if (index === -1) {
        throw new Error(`Alışkanlık bulunamadı: ${id}`);
      }

      const current = habits[index];
      const merged: Habit = {
        ...current,
        name: patch.name !== undefined ? patch.name.trim() : current.name,
        icon: patch.icon !== undefined ? patch.icon.trim() : current.icon,
        category: patch.category !== undefined ? patch.category : current.category,
        unit: patch.unit !== undefined ? (patch.unit ? patch.unit.trim() : null) : current.unit,
        dailyGoal: patch.dailyGoal !== undefined ? patch.dailyGoal : current.dailyGoal,
        step: patch.step !== undefined ? patch.step : current.step,
        repeatDays:
          patch.repeatDays !== undefined
            ? [...patch.repeatDays].sort((a, b) => a - b)
            : current.repeatDays,
        reminderTime:
          patch.reminderTime !== undefined ? patch.reminderTime : current.reminderTime,
        archived: patch.archived !== undefined ? patch.archived : current.archived
      };

      habits[index] = merged;
      updated = merged;
      return habits;
    });

    if (!updated) {
      throw new Error(`Alışkanlık güncellenemedi: ${id}`);
    }

    return updated;
  }

  public async archive(userId: string, id: string): Promise<void> {
    let found = false;

    await this.store.update((habits) => {
      const index = habits.findIndex((h) => h.id === id && h.userId === userId);
      if (index === -1) {
        throw new Error(`Alışkanlık bulunamadı: ${id}`);
      }
      habits[index].archived = true;
      found = true;
      return habits;
    });

    if (!found) {
      throw new Error(`Alışkanlık bulunamadı: ${id}`);
    }
  }

  public async deleteAllByUser(userId: string): Promise<void> {
    await this.store.update((habits) => habits.filter((h) => h.userId !== userId));
  }
}
