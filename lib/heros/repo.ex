defmodule Heros.Repo do
  use Ecto.Repo,
    otp_app: :heros,
    adapter: Ecto.Adapters.Postgres
end
