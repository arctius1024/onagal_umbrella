# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :onagal_simple,
  ecto_repos: [OnagalSimple.Repo],
  generators: [context_app: false]

# Configures the endpoint
config :onagal_simple, OnagalSimple.Endpoint,
  url: [host: "onagal.thexproject.us"],
  render_errors: [view: OnagalSimple.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Onagal.PubSub,
  live_view: [signing_salt: "aXObZbe9"]

config :onagal_web,
  ecto_repos: [Onagal.Repo],
  generators: [context_app: :onagal]

# Configures the endpoint
config :onagal_web, OnagalWeb.Endpoint,
  url: [host: "onagal.thexproject.us"],
  render_errors: [view: OnagalWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Onagal.PubSub,
  live_view: [signing_salt: "+hNCe+L+"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/onagal_simple/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure Mix tasks and generators
config :onagal,
  ecto_repos: [Onagal.Repo]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :onagal, Onagal.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false


# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/onagal_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :onagal_fs, Onagal.Fs,
  watch_dir: System.get_env("WATCH_DIR"),
  manage_dir: System.get_env("MANAGE_DIR")
