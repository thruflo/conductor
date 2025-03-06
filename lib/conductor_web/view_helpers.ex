defmodule ConductorWeb.ViewHelpers do
  import Phoenix.HTML, only: [raw: 1]

  @whitelist ["audio", "images"]

  def minimum_one_trip_latency do
    value = Application.fetch_env!(:conductor, :minimum_one_trip_latency)

    Jason.encode!(value)
    |> raw()
  end

  def asset_manifest do
    Application.get_env(:conductor, ConductorWeb.Endpoint)
    |> Keyword.get(:cache_static_manifest)
    |> render_manifest()
  end

  defp render_manifest(nil) do
    "{}"
  end

  defp render_manifest(path) when is_binary(path) do
    Application.app_dir(:conductor, path)
    |> File.read!()
    |> Jason.decode!()
    |> Map.fetch!("latest")
    |> Enum.filter(fn {k, _v} -> String.starts_with?(k, @whitelist) end)
    |> Enum.into(%{})
    |> Jason.encode!()
    |> raw()
  end
end
