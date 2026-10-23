import { HabitRepository, JsonHabitRepository } from '../repositories/habitRepository.js';
import { HabitLogRepository, JsonHabitLogRepository } from '../repositories/habitLogRepository.js';
import { UserSettingsRepository, JsonUserSettingsRepository } from '../repositories/settingsRepository.js';
import { CalendarMonthResponse, CalendarDayDetailResponse } from '../domain/calendar.js';
import { formatDateInTimezone } from './domainRules.js';
import { calculateMonthCalendar, calculateDayDetail } from './calendarRules.js';

export interface CalendarServiceOptions {
  habitRepository?: HabitRepository;
  habitLogRepository?: HabitLogRepository;
  settingsRepository?: UserSettingsRepository;
}

export class CalendarService {
  private habitRepository: HabitRepository;
  private habitLogRepository: HabitLogRepository;
  private settingsRepository: UserSettingsRepository;

  constructor(options?: CalendarServiceOptions) {
    this.habitRepository = options?.habitRepository ?? new JsonHabitRepository();
    this.habitLogRepository = options?.habitLogRepository ?? new JsonHabitLogRepository();
    this.settingsRepository = options?.settingsRepository ?? new JsonUserSettingsRepository();
  }

  public async getMonthCalendar(userId: string, requestedMonth?: string): Promise<CalendarMonthResponse> {
    const settings = await this.settingsRepository.getByUserId(userId);
    const todayDateStr = formatDateInTimezone(new Date(), settings.timezone);

    const month = requestedMonth && /^\d{4}-\d{2}$/.test(requestedMonth)
      ? requestedMonth
      : todayDateStr.slice(0, 7);

    const habits = await this.habitRepository.listByUser(userId, false);
    // Tüm logları al (longestStreak ve geçmiş hesaplar için)
    const logs = await this.habitLogRepository.listByUserAndDateRange(userId);

    return calculateMonthCalendar({
      month,
      habits,
      logs,
      todayDateStr,
      streakFreezeCount: settings.streakFreezeCount
    });
  }

  public async getDayDetail(userId: string, dateStr: string): Promise<CalendarDayDetailResponse> {
    const settings = await this.settingsRepository.getByUserId(userId);
    const todayDateStr = formatDateInTimezone(new Date(), settings.timezone);

    const habits = await this.habitRepository.listByUser(userId, false);
    const logs = await this.habitLogRepository.listByUserAndDateRange(userId, dateStr, dateStr);

    return calculateDayDetail({
      dateStr,
      habits,
      logs,
      todayDateStr
    });
  }
}
