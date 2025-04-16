defmodule FarneboFlora.Repo do
  use Ecto.Repo,
    otp_app: :farnebo_flora,
    adapter: Ecto.Adapters.Postgres
end
