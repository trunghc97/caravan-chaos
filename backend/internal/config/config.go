package config

import "os"

type Config struct {
	Addr        string
	DatabaseURL string
	RedisAddr   string
}

func FromEnv() Config {
	return Config{
		Addr:        envOr("HTTP_ADDR", ":8080"),
		DatabaseURL: envOr("DATABASE_URL", "postgres://caravan:caravan@localhost:5432/caravan_chaos?sslmode=disable"),
		RedisAddr:   envOr("REDIS_ADDR", "localhost:6379"),
	}
}

func envOr(key string, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
