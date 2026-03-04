import Redis from 'ioredis';

export const {{FEATURE_PASCAL}}RedisProvider = {
  provide: '{{REDIS_TOKEN}}',
  useValue: new Redis({
    host: process.env.INFRAREDISHOST,
    port: Number(process.env.INFRAREDISPORT),
    password: process.env.INFRAREDISPASS,
    tls: {},
  }),
};
