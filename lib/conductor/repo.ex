defmodule Conductor.Repo do
  use Ecto.Repo,
    otp_app: :conductor,
    adapter: Ecto.Adapters.Postgres
end
