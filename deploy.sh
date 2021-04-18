source .env
export MIX_ENV=prod

npm run deploy --prefix ./assets/
mix phx.digest

mix compile
mix ecto.migrate

kill -9 $(lsof -t -i:5000)

PORT=5000 elixir --erl "-detached" -S mix phx.server