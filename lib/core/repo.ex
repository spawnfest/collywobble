defmodule Core.Repo do
  use Ecto.Repo,
    otp_app: :collywobble,
    adapter: Ecto.Adapters.Postgres
end
