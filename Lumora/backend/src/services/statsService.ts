import { HabitRepository, JsonHabitRepository } from '../repositories/habitRepository.js';
import { HabitLogRepository, JsonHabitLogRepository } from '../repositories/habitLogRepository.js';
import { UserSettingsRepository, JsonUserSettingsRepository } from '../repositories/settingsRepository.js';
import { StatsRange, StatsResponse } from '../domain/stats.js';
import { formatDateInTimezone } from './domainRules.js';
import { calculateStats } from './statsRules.js';

export interface StatsServiceOptions {
  habitRepository?: HabitRepository;
  habitLogRepository?: HabitLogRepository;
  settingsRepository?: UserSettingsRepository;
}

export class StatsService {
  private habitRepository: HabitRepository;
  private habitLogRepository: HabitLogRepository;
  private settingsRepository: UserSettingsRepository;

  constructor(options?: StatsServiceOptions) {
    this.habitRepository = options?.habitRepository ?? new JsonHabitRepository();
    this.habitLogRepository = options?.habitLogRepository ?? new JsonHabitLogRepository();
    this.settingsRepository = options?.settingsRepository ?? new JsonUserSettingsRepository();
  }

  public async getStats(userId: string, requestedRange?: string): Promise<StatsResponse> {
    const range: StatsRange =
      requestedRange === 'monthly' || requestedRange === 'all'
        ? requestedRange
        : 'weekly';

    const settings = await this.settingsRepository.getByUserId(userId);
    const todayDateStr = formatDateInTimezone(new Date(), settings.timezone);

    const habits = await this.habitRepository.listByUser(userId, false);
    const logs = await this.habitLogRepository.listByUserAndDateRange(userId);

    return calculateStats({
      range,
      habits,
      logs,
      todayDateStr,
      streakFreezeCount: settings.streakFreezeCount,
      timezone: settings.timezone
    });
  }
}
