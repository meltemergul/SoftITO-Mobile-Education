import path from 'node:path';
import { JsonStore } from '../storage/jsonStore.js';
import { User, usersArraySchema } from '../domain/user.js';

export interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  create(user: User): Promise<User>;
  update(id: string, patch: Partial<User>): Promise<User>;
}

export class JsonUserRepository implements UserRepository {
  private store: JsonStore<User[]>;

  constructor(customStoreOrPath?: JsonStore<User[]> | string) {
    if (customStoreOrPath instanceof JsonStore) {
      this.store = customStoreOrPath;
    } else {
      const filePath =
        typeof customStoreOrPath === 'string'
          ? customStoreOrPath
          : path.resolve(process.cwd(), 'data/users.json');

      this.store = new JsonStore<User[]>({
        filePath,
        schema: usersArraySchema,
        defaultValue: []
      });
    }
  }

  public async findById(id: string): Promise<User | null> {
    const users = await this.store.read();
    const found = users.find((u) => u.id === id);
    return found ? { ...found } : null;
  }

  public async findByEmail(email: string): Promise<User | null> {
    const normalized = email.trim().toLowerCase();
    const users = await this.store.read();
    const found = users.find((u) => u.email && u.email.toLowerCase() === normalized);
    return found ? { ...found } : null;
  }

  public async create(user: User): Promise<User> {
    await this.store.update((users) => {
      return [...users, user];
    });
    return { ...user };
  }

  public async update(id: string, patch: Partial<User>): Promise<User> {
    let updatedUser: User | null = null;
    await this.store.update((users) => {
      const index = users.findIndex((u) => u.id === id);
      if (index === -1) {
        throw new Error(`Kullanıcı bulunamadı: ${id}`);
      }
      users[index] = { ...users[index], ...patch };
      updatedUser = users[index];
      return users;
    });

    if (!updatedUser) {
      throw new Error(`Kullanıcı güncellenemedi: ${id}`);
    }
    return updatedUser;
  }
}
