import { describe, it, expect } from 'vitest';
import request from 'supertest';
import { app } from './server.js';

describe('Server & Health Check', () => {
  it('GET /health 200 dönmeli ve status: ok içermeli', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.timestamp).toBeDefined();
  });

  it('Bilinmeyen rotada 404 ve standart hata formatı dönmeli', async () => {
    const res = await request(app).get('/api/unknown-route');
    expect(res.status).toBe(404);
    expect(res.body).toEqual({
      error: {
        code: 'NOT_FOUND',
        message: 'İstenen kaynak bulunamadı.'
      }
    });
  });
});
