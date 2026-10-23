import { UserRepository, JsonUserRepository } from '../repositories/userRepository.js';
import { UserSettingsRepository, JsonUserSettingsRepository } from '../repositories/settingsRepository.js';
import { HabitRepository, JsonHabitRepository } from '../repositories/habitRepository.js';
import { HabitLogRepository, JsonHabitLogRepository } from '../repositories/habitLogRepository.js';
import { FavoriteRepository, JsonFavoriteRepository } from '../repositories/favoriteRepository.js';
import { toSafeUser, SafeUser } from '../domain/user.js';
import { UserSettings } from '../domain/settings.js';
import {
  ProfileResponse,
  UpdateProfileInput,
  updateProfileInputSchema,
  UpdateSettingsInput,
  updateSettingsInputSchema
} from '../domain/profile.js';
import { calculateHabitStreak } from './domainRules.js';
import { evaluateBadges, calculateUserLevelWithBadges } from './badgeRules.js';

export interface ProfileServiceOptions {
  userRepository?: UserRepository;
  settingsRepository?: UserSettingsRepository;
  habitRepository?: HabitRepository;
  habitLogRepository?: HabitLogRepository;
  favoriteRepository?: FavoriteRepository;
}

export class ProfileService {
  private userRepo: UserRepository;
  private settingsRepo: UserSettingsRepository;
  private habitRepo: HabitRepository;
  private logRepo: HabitLogRepository;
  private favoriteRepo: FavoriteRepository;

  constructor(options?: ProfileServiceOptions) {
    this.userRepo = options?.userRepository ?? new JsonUserRepository();
    this.settingsRepo = options?.settingsRepository ?? new JsonUserSettingsRepository();
    this.habitRepo = options?.habitRepository ?? new JsonHabitRepository();
    this.logRepo = options?.habitLogRepository ?? new JsonHabitLogRepository();
    this.favoriteRepo = options?.favoriteRepository ?? new JsonFavoriteRepository();
  }

  public async getProfile(userId: string): Promise<ProfileResponse> {
    const user = await this.userRepo.findById(userId);
    if (!user) {
      throw new Error('Kullanıcı bulunamadı.');
    }

    const settings = await this.settingsRepo.getByUserId(userId);
    const habits = await this.habitRepo.listByUser(userId, false);
    const logs = await this.logRepo.listByUserAndDateRange(userId);

    // En iyi seri (longest streak) hesaplama
    const todayDateStr = new Date().toISOString().slice(0, 10);
    let bestStreak = 0;
    for (const habit of habits) {
      const streakResult = calculateHabitStreak({
        habit,
        logs,
        todayDateStr,
        availableFreezes: settings.streakFreezeCount
      });
      if (streakResult.longestStreak > bestStreak) {
        bestStreak = streakResult.longestStreak;
      }
    }

    // Seviye hesaplama
    const badgeEval = evaluateBadges({ habits, logs });
    const levelInfo = calculateUserLevelWithBadges(logs, badgeEval.badges);

    return {
      user: toSafeUser(user),
      quickMetrics: {
        bestStreak,
        totalGoals: habits.length,
        level: levelInfo.level
      }
    };
  }

  public async updateProfile(userId: string, input: UpdateProfileInput): Promise<SafeUser> {
    const parsed = updateProfileInputSchema.parse(input);
    const updated = await this.userRepo.update(userId, parsed);
    return toSafeUser(updated);
  }

  public async getSettings(userId: string): Promise<UserSettings> {
    return this.settingsRepo.getByUserId(userId);
  }

  public async updateSettings(
    userId: string,
    input: UpdateSettingsInput
  ): Promise<UserSettings> {
    const parsed = updateSettingsInputSchema.parse(input);
    const current = await this.settingsRepo.getByUserId(userId);

    // Bildirim ayarlarını derinlemesine birleştir (partial merge)
    let mergedNotifications = current.notifications;
    if (parsed.notifications) {
      mergedNotifications = {
        ...current.notifications,
        ...parsed.notifications,
        morningMotivation: {
          ...current.notifications.morningMotivation,
          ...(parsed.notifications.morningMotivation ?? {})
        },
        eveningChainCheck: {
          ...current.notifications.eveningChainCheck,
          ...(parsed.notifications.eveningChainCheck ?? {})
        }
      };
    }

    const patch: Partial<UserSettings> = {
      ...(parsed.theme ? { theme: parsed.theme } : {}),
      ...(parsed.weekStartsOn !== undefined ? { weekStartsOn: parsed.weekStartsOn } : {}),
      ...(parsed.timezone ? { timezone: parsed.timezone } : {}),
      ...(parsed.streakFreezeCount !== undefined ? { streakFreezeCount: parsed.streakFreezeCount } : {}),
      notifications: mergedNotifications
    };

    return this.settingsRepo.update(userId, patch);
  }

  public async exportData(
    userId: string,
    format: 'csv' | 'json' = 'json'
  ): Promise<{ contentType: string; filename: string; data: string | object }> {
    const user = await this.userRepo.findById(userId);
    if (!user) {
      throw new Error('Kullanıcı bulunamadı.');
    }

    const settings = await this.settingsRepo.getByUserId(userId);
    const habits = await this.habitRepo.listByUser(userId, true); // Arşivlenenler dahil
    const logs = await this.logRepo.listByUserAndDateRange(userId);
    const favorites = await this.favoriteRepo.listFavorites(userId);

    const safe = toSafeUser(user);
    const timestamp = new Date().toISOString().slice(0, 10);

    if (format === 'csv') {
      const habitMap = new Map(habits.map((h) => [h.id, h]));

      // CSV oluşturma: Alışkanlıklar ve Loglar
      const lines: string[] = [];
      lines.push('# Lumora Veri Dışa Aktarımı');
      lines.push(`Kullanıcı: ${safe.displayName} (${safe.email ?? 'Misafir'})`);
      lines.push(`Tarih: ${new Date().toISOString()}`);
      lines.push('');
      lines.push('--- ALISKANLIKLAR ---');
      lines.push('id,name,category,dailyGoal,unit,step,repeatDays,archived,createdAt');
      for (const h of habits) {
        lines.push(
          `"${h.id}","${h.name}","${h.category}",${h.dailyGoal},"${h.unit ?? ''}",${h.step},"${h.repeatDays.join('-')}",${h.archived},"${h.createdAt}"`
        );
      }

      lines.push('');
      lines.push('--- TAMAMLANMA KAYITLARI (LOGS) ---');
      lines.push('date,habitId,habitName,category,amount,dailyGoal,completed');
      for (const l of logs) {
        const habit = habitMap.get(l.habitId);
        lines.push(
          `"${l.date}","${l.habitId}","${habit?.name ?? ''}","${habit?.category ?? ''}",${l.amount},${habit?.dailyGoal ?? 0},${l.completed}`
        );
      }

      return {
        contentType: 'text/csv; charset=utf-8',
        filename: `lumora_export_${timestamp}.csv`,
        data: lines.join('\n')
      };
    }

    // JSON dışa aktarımı
    return {
      contentType: 'application/json',
      filename: `lumora_export_${timestamp}.json`,
      data: {
        exportedAt: new Date().toISOString(),
        user: safe,
        settings,
        habits,
        logs,
        favorites
      }
    };
  }

  public async deleteAccount(userId: string): Promise<void> {
    const user = await this.userRepo.findById(userId);
    if (!user) {
      throw new Error('Kullanıcı bulunamadı.');
    }

    // architecture-skill.md Bölüm 11:
    // DELETE /account kullanıcının tüm kayıtlarını (kullanıcı, alışkanlık, log, ayar, favori) kalıcı siler.
    await Promise.all([
      this.userRepo.delete(userId),
      this.habitRepo.deleteAllByUser(userId),
      this.logRepo.deleteAllByUser(userId),
      this.settingsRepo.deleteAllByUser(userId),
      this.favoriteRepo.deleteAllByUser(userId)
    ]);
  }
}
