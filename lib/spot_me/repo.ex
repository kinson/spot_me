defmodule SpotMe.Repo do
  use Ecto.Repo,
    otp_app: :spot_me,
    adapter: Ecto.Adapters.Postgres
end
