
# Conductor

This is a (slightly crazy) [Phoenix.Sync](https://hexdocs.pm/phoenix_sync) demo app. It showcases different modes of real-time sync with Phoenix and ElectricSQL.

## Run

* Run `mix setup` to install and setup dependencies
* Start the Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Steps

### 1. Sound check

First there's a "sound check" where users connect to a LiveView and sounds are pushed to them over a Phoenix Stream.

Users open the app at `/app`. Push sounds by inserting them into the database:

```sql
INSERT INTO sounds (name) VALUES ('clap');
```

They will be streamed through to the LiveView and played using a phx-hook.

### 2. Performance

Then users choose a track the'd like to play (bass, drums, keys), audio data syncs in (as tensors, via pgvector) and everyone (hopefully) plays back the different tracks from the same song in unison, creating a synchronized "orchestra performance".

Send an instruction to all the clients to redirect to `/app/sync`:

```shell
mix send_instruction redirect "/app/sync"
```

Sync the audio data (as tensors, through pgvector) into the clients using:

```shell
# mix populate $song_name $track_name
# e.g.:
mix populate arena bass
```

Then, when everyone is ready, schedule the performance using:

```shell
mix send_instruction schedule 10 # seconds in the future
```

There will be a shared countdown and then everything goes crazy.

Good luck!

## Learn more

* Docs: https://hexdocs.pm/phoenix_sync
* Phoenix: https://phoenixframework.com
* ElectricSQL: https://electric-sql.com
* Source: https://github.com/thruflo/conductor
