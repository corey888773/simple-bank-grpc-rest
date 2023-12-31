package util

import (
	"time"

	"github.com/spf13/viper"
)

type Config struct {
	DbSource            string        `mapstructure:"DB_SOURCE"`
	HttpServerAddress   string        `mapstructure:"HTTP_SERVER_ADDRESS"`
	GrpcServerAddress   string        `mapstructure:"GRPC_SERVER_ADDRESS"`
	RedisAddress        string        `mapstructure:"REDIS_ADDRESS"`
	TokenSymmetricKey   string        `mapstructure:"TOKEN_SYMMETRIC_KEY"`
	MigrationUrl        string        `mapstructure:"MIGRATION_URL"`
	Environment         string        `mapstructure:"ENVIRONMENT"`
	AccessTokenDuration time.Duration `mapstructure:"ACCESS_TOKEN_DURATION"`
	RefreshTokeDuration time.Duration `mapstructure:"REFRESH_TOKEN_DURATION"`
	EmailSenderName     string        `mapstructure:"EMAIL_SENDER_NAME"`
	EmailSenderAddress  string        `mapstructure:"EMAIL_SENDER_ADDRESS"`
	EmailSenderPassword string        `mapstructure:"EMAIL_SENDER_PASSWORD"`
}

func LoadConfig(path string) (config Config, err error) {
	viper.AddConfigPath(path)
	viper.SetConfigName("app")
	viper.SetConfigType("env") // can be json etc.

	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		return
	}

	err = viper.Unmarshal(&config)
	return
}
