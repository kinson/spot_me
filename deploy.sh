source .env
export MIX_ENV=prod
export PORT=5000

echo "Stopping Application"
_build/prod/rel/spot_me/bin/spot_me stop

echo "Fetching Latest Deps"
mix deps.get --only prod

echo "Building Application"
npm run deploy --prefix ./assets/
mix phx.digest
mix release --overwrite

echo "Migrating"
mix ecto.migrate

echo "Starting Application"
build/prod/rel/spot_me/bin/spot_me daemon
