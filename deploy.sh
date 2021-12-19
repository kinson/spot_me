source .env
export MIX_ENV=prod

kill -9 $(lsof -t -i:5000)

mix deps.get --only prod
npm run deploy --prefix ./assets/
mix phx.digest

mix compile

mix ecto.migrate

PORT=5000 elixir --erl "-detached" -S mix phx.server
