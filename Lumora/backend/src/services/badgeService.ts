import { HabitRepository, JsonHabitRepository } from '../repositories/habitRepository.js';
import { HabitLogRepository, JsonHabitLogRepository } from '../repositories/habitLogRepository.js';
import { BadgesResponse } from '../domain/badge.js';
import { LevelInfo } from '../domain/constants.js';
import { evaluateBadges, calculateUserLevelWithBadges } from './badgeRules.js';

export interface BadgeServiceOptions {
  habitRepository?: HabitRepository;
  habitLogRepository?: HabitLogRepository;
}

export class BadgeService {
  private habitRepository: HabitRepository;
  private habitLogRepository: HabitLogRepository;

  constructor(options?: BadgeServiceOptions) {
    this.habitRepository = options?.habitRepository ?? new JsonHabitRepository();
    this.habitLogRepository = options?.habitLogRepository ?? new JsonHabitLogRepository();
  }

  public async getBadges(userId: string): Promise<BadgesResponse> {
    const habits = await this.habitRepository.listByUser(userId, false);
    const logs = await this.habitLogRepository.listByUserAndDateRange(userId);

    return evaluateBadges({ habits, logs });
  }

  public async getLevel(userId: string): Promise<LevelInfo> {
    const habits = await this.habitRepository.listByUser(userId, false);
    const logs = await this.habitLogRepository.listByUserAndDateRange(userId);

    const badgeEvaluation = evaluateBadges({ habits, logs });
    return calculateUserLevelWithBadges(logs, badgeEvaluation.badges);
  }
}
