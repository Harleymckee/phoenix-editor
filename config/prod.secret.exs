use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :editor, Editor.Endpoint,
  secret_key_base: "H1SJ0TcMgJvam5degP5htDZMFxxfK7PpDf5PgBp4YtaKXnilrfwbnqWqU6XU9eqH"

# Configure your database
config :editor, Editor.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "editor_prod",
  pool_size: 20
