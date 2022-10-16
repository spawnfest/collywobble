import Config

# Configure your database
#
# We don't run a server during test. If one is required,
# you can enable the server option below.
config :collywobble, Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "kEYEPlpjlSmKfgxkWlFucPOeJtDI4kdN0sufzqBC9tAZuduJZoltyYgyXZn7mNRQ",
  server: false

# In test we don't send emails.
config :collywobble, Core.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

config :pages, :phoenix_endpoint, Web.Endpoint

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
