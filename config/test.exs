import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pr_zero, PrZeroWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "3NwQYRXb8oCSHifQ0wVRbHys9mrUwouONZi+8YTLuCi6bgEz3rh8xY/pC1afpHbR",
  server: false

# In test we don't send emails.
config :pr_zero, PrZero.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :info

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

import_config "test.secret.exs"
