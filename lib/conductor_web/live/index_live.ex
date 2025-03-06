defmodule ConductorWeb.IndexLive do
  @moduledoc """
  LiveView demonstrating Phoenix.Sync using
  `Phoenix.Sync.LiveView.sync_stream/3`.
  """
  use ConductorWeb, :live_view

  alias Conductor.{Audio, Demo}

  @doc """
  Sync instructions and sounds to the client, via the LiveView.
  """
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:ready, false)
      |> assign(:started, false)
      |> sync_stream(:instructions, Demo.Instruction)
      |> sync_stream(:sounds, Audio.Sound)

    {:ok, socket}
  end

  def handle_params(%{"path" => ["sync" | _rest]}, _uri, socket) do
    {:noreply, assign(socket, :demo, :sync)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :demo, :push)}
  end

  def handle_event("start", _params, socket) do
    {:noreply, assign(socket, :started, true)}
  end

  # NTP-like time synchronization over the LiveView socket
  def handle_event("time", %{"t1" => t1}, socket) when is_integer(t1) do
    s1 = System.system_time(:millisecond)

    {:noreply, push_event(socket, "time", %{t1: t1, s1: s1})}
  end

  def handle_info({:sync, {:sounds, :live}}, socket) do
    {:noreply, assign(socket, :ready, true)}
  end

  def handle_info({:sync, {:sounds, :loaded}}, socket) do
    {:noreply, socket}
  end

  # Monitor the stream for instructions to control the demo.
  def handle_info(
        {:sync, {:"$electric_event", :instructions, :insert, instruction, _}},
        socket
      ) do
    handle_instruction(instruction, socket)
  end

  # Pass all other electric events to `electric_stream_update`.
  # This is required for the `electric_stream` integration to work.
  def handle_info({:sync, event}, socket) do
    {:noreply, sync_stream_update(socket, event, at: 0)}
  end

  defp handle_instruction(%{name: "redirect", value: path}, socket) do
    {:noreply, redirect(socket, to: path)}
  end

  defp handle_instruction(
         %{name: "schedule", value: seconds},
         %{assigns: %{started: true, demo: :sync}} = socket
       ) do
    delay_ms =
      case seconds do
        nil -> 10_000
        val -> String.to_integer(val) * 1000
      end

    time = System.system_time(:millisecond) + delay_ms

    {:noreply, push_event(socket, "schedule", %{time: time})}
  end

  defp handle_instruction(
         %{name: "volume", value: percentage},
         %{assigns: %{started: true, demo: :sync}} = socket
       ) do
    level =
      case percentage do
        nil -> 1.0
        val -> String.to_integer(val) / 100
      end

    {:noreply, push_event(socket, "volume", %{level: level})}
  end

  defp handle_instruction(_instruction, socket), do: {:noreply, socket}
end
