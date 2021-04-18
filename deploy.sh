source .env
export MIX_ENV=prod

npm run deploy --prefix ./assets/
mix phx.digest

mix compile
mix ecto.migrate

pkill -f "SpotMeProcess"

bash -c "PORT=5000 exec -a SpotMeProcess elixir --erl "-detached" -S mix phx.server"