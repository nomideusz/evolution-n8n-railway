FROM redis:7-alpine

# No config file → redis binds all interfaces including IPv6 (required on
# Railway's private network). requirepass satisfies protected-mode.
# appendonly matches upstream compose; cache-only data, volume optional.
CMD ["sh", "-c", "redis-server --appendonly yes --requirepass \"$REDIS_PASSWORD\""]
