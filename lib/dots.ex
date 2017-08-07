defmodule Dots do
  use GenServer
  require Logger

  @process_name :dots

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{})
    Process.register(pid, @process_name)
    {:ok, pid}
  end

  def get do
    GenServer.call(@process_name, :get)
  end

  def update(dot) do
    GenServer.cast(@process_name, {:update, dot})
  end

  def remove(dot) do
    GenServer.cast(@process_name, {:remove, dot})
  end

  def tell_clients_about_yourself do
    GenServer.cast(@process_name, :broadcast)
  end

  def init(dot_map) do
    {:ok, dot_map}
  end

  def handle_cast({:update, %{name: name} = dot}, dot_map) do
    updated_dot_map = Map.put(dot_map, name, dot)
    broadcast_dots(updated_dot_map)
    {:noreply, updated_dot_map}
  end

  def handle_cast({:remove, %{name: name}}, dot_map) do
    updated_dot_map = Map.delete(dot_map, name)
    broadcast_dots(updated_dot_map)
    {:noreply, updated_dot_map}
  end

  def handle_cast(:broadcast, dot_map) do
    broadcast_dots(dot_map)
    {:noreply, dot_map}
  end

  def handle_call(:get, _from, dots) do
    {:reply, dots_list(dots), dots}
  end

  defp dots_list(dot_map) do
    dot_map
    |> Enum.with_index
    |> Enum.map(fn {{_name, value}, index} ->
      Map.put(value, :index, index)
    end)
  end

  defp broadcast_dots(dot_map) do
    Logger.info("Broadcasting dots")
    DotsWeb.Endpoint.broadcast!("dot:channel", "dot:update", %{dots: dots_list(dot_map)})
  end
end
