# General application configuration
import Config

config :my_super_app,
  ecto_repos: [MySuperApp.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :my_super_app, MySuperAppWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: MySuperAppWeb.ErrorHTML, json: MySuperAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MySuperApp.PubSub,
  live_view: [signing_salt: "2PH/cSR5"]

config :finch,
  name: MySuperApp.Finch,
  pools: [
    default: [size: 10, count: 100]
  ]

# Mailjet credentials from environment variables
config :my_super_app, MySuperApp.Mailer,
  adapter: Swoosh.Adapters.Mailjet,
  api_key: System.get_env("MAILJET_API_KEY"),
  secret: System.get_env("MAILJET_SECRET_KEY")

config :swoosh,
  api_client: Swoosh.ApiClient.Finch,
  finch_name: MySuperApp.Finch

config :my_super_app, Oban,
  repo: MySuperApp.Repo,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60}
  ],
  queues: [default: 10]

# Configure esbuild
config :esbuild,
  version: "0.16.4",
  my_super_app: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind
config :tailwind,
  version: "3.4.0",
  my_super_app: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Cloudinary credentials from environment variables
config :cloudex,
  api_key: System.get_env("CLOUDEX_API_KEY"),
  secret: System.get_env("CLOUDEX_SECRET_KEY"),
  cloud_name: System.get_env("CLOUDEX_CLOUD_NAME")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config
import_config "#{config_env()}.exs"

# Basic authentication credentials from environment variables
config :my_super_app, :basic_auth,
  username: System.get_env("BASIC_AUTH_USERNAME"),
  password: System.get_env("BASIC_AUTH_PASSWORD")

moon_config_path = "#{File.cwd!()}/deps/moon/config/surface.exs"

if File.exists?(moon_config_path) do
  import_config(moon_config_path)
end
