Postgrex.Types.define(
  Conductor.PostgrexTypes,
  [Pgvector.Extensions.Halfvec] ++ Ecto.Adapters.Postgres.extensions(),
  []
)
