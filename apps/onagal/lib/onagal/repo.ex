defmodule Onagal.Repo do
  use Ecto.Repo,
    otp_app: :onagal,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 12
end
