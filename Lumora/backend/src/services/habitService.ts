import { AppError } from '../middleware/errorHandler.js';
import { HabitRepository } from '../repositories/habitRepository.js';
import { HabitLogRepository } from '../repositories/habitLogRepository.js';
import {
  CreateHabitInput,
  Habit,
  HABIT_TEMPLATES,
  HabitTemplate,
  UpdateHabitInput
} from '../domain/habit.js';
import { HabitLog, PutHabitLogInput } from '../domain/habitLog.js';

export class HabitService {
  constructor(
    private habitRepository: HabitRepository,
    private habitLogRepository: HabitLogRepository
  ) {}

  public async listHabits(userId: string, includeArchived = false): Promise<Habit[]> {
    return this.habitRepository.listByUser(userId, includeArchived);
  }

  public async getHabitById(userId: string, habitId: string): Promise<Habit> {
    const habit = await this.habitRepository.getById(userId, habitId);
    if (!habit) {
      throw new AppError('Alışkanlık bulunamadı.', 404, 'NOT_FOUND');
    }
    return habit;
  }

  public async createHabit(userId: string, input: CreateHabitInput): Promise<Habit> {
    return this.habitRepository.create(userId, input);
  }

  public async updateHabit(
    userId: string,
    habitId: string,
    patch: UpdateHabitInput
  ): Promise<Habit> {
    const existing = await this.habitRepository.getById(userId, habitId);
    if (!existing) {
      throw new AppError('Alışkanlık bulunamadı.', 404, 'NOT_FOUND');
    }

    return this.habitRepository.update(userId, habitId, patch);
  }

  public async archiveHabit(userId: string, habitId: string): Promise<void> {
    const existing = await this.habitRepository.getById(userId, habitId);
    if (!existing) {
      throw new AppError('Alışkanlık bulunamadı.', 404, 'NOT_FOUND');
    }

    await this.habitRepository.archive(userId, habitId);
  }

  public getTemplates(): readonly HabitTemplate[] {
    return HABIT_TEMPLATES;
  }

  public async putLog(
    userId: string,
    habitId: string,
    date: string,
    input: PutHabitLogInput
  ): Promise<HabitLog> {
    // Alışkanlığın kullanıcıya ait olup olmadığı kontrol edilir (arşivlenmiş olsa bile log güncellenebilir)
    const habits = await this.habitRepository.listByUser(userId, true);
    const habit = habits.find((h) => h.id === habitId);
    if (!habit) {
      throw new AppError('Alışkanlık bulunamadı.', 404, 'NOT_FOUND');
    }

    const currentLog = await this.habitLogRepository.findByUserAndHabitAndDate(
      userId,
      habitId,
      date
    );

    let newAmount: number;
    if (input.amount !== undefined) {
      newAmount = input.amount;
    } else if (input.delta !== undefined) {
      const currentAmount = currentLog ? currentLog.amount : 0;
      newAmount = currentAmount + input.delta;
    } else {
      throw new AppError(
        'En az bir miktar (amount) veya değişim (delta) değeri belirtilmelidir.',
        400,
        'VALIDATION_ERROR'
      );
    }

    // Kural: amount 0'ın altına inmez
    newAmount = Math.max(0, newAmount);

    // Kural: completed, amount >= dailyGoal olunca otomatik true
    const completed = newAmount >= habit.dailyGoal;

    return this.habitLogRepository.upsert(
      userId,
      habitId,
      date,
      newAmount,
      completed
    );
  }

  public async getLogs(
    userId: string,
    from?: string,
    to?: string
  ): Promise<HabitLog[]> {
    return this.habitLogRepository.listByUserAndDateRange(userId, from, to);
  }
}
