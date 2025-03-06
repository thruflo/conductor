defmodule ConductorWeb.IndexLiveTest do
  use ConductorWeb.ConnCase
  alias Conductor.Audio

  test "mount live", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/app")

    assert html =~ "Conductor"
  end

  test "play sound", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/app")

    Process.sleep(500)

    num_before =
      view
      |> render()
      |> String.split("<li ")
      |> Enum.count()

    assert {:ok, _sound} = Audio.create_sound(%{name: "clap"})
    Process.sleep(500)

    num_after =
      view
      |> render()
      |> String.split("<li ")
      |> Enum.count()

    assert num_after == num_before + 1
  end
end
