import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :onagal, Onagal.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "onagal_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :onagal_web, OnagalWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "UO8dg4BsJ+mKvDN6gE3feMvyvrt8HtlInsOPnskDkQEMrybjSTl4T1Tz4BKhMtAo",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# In test we don't send emails.
config :onagal, Onagal.Mailer, adapter: Swoosh.Adapters.Test

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
