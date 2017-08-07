defmodule Dot do
  use GenServer

  def new(name, color) do
    state = %{
      name: name,
      color: color,
      pulsing: "false",
    }
    {:ok, pid} = GenServer.start_link(__MODULE__, state)
    Process.register(pid, safe_name(name))
    {:ok, pid}
  end

  def get(name) do
    call(name, :get)
  end

  def set_color(name, color) do
    cast(name, {:set_color, color})
  end

  def start_pulse(name) do
    cast(name, :start_pulse)
  end

  def stop_pulse(name) do
    cast(name, :stop_pulse)
  end

  def kill(name) do
    cast(name, :kill)
  end

  def init(state) do
    tell_dots_about_myself(state)
    {:ok, state}
  end

  def handle_call(:color, _from, %{color: color} = state) do
    {:reply, color, state}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:set_color, color}, dot) do
    dot = %{dot | color: color}
    tell_dots_about_myself(dot)
    {:noreply, dot}
  end

  def handle_cast(:kill, state) do
    {:stop, :normal, state}
  end

  def handle_cast(:start_pulse, dot) do
    dot = %{dot | pulsing: "true"}
    tell_dots_about_myself(dot)
    {:noreply, dot}
  end

  def handle_cast(:stop_pulse, dot) do
    dot = %{dot | pulsing: "false"}
    tell_dots_about_myself(dot)
    {:noreply, dot}
  end


  def terminate(_reason, state) do
    tell_dots_i_died(state)
  end

  defp tell_dots_about_myself(dot) do
    Dots.update(dot)
  end

  defp tell_dots_i_died(dot) do
    Dots.remove(dot)
  end

  defp safe_name(name) when name |> is_binary, do: String.to_atom(name)
  defp safe_name(name) when name |> is_atom, do: name

  defp call(name, arg) do
    name
    |> safe_name
    |> GenServer.call(arg)
  end

  defp cast(name, arg) do
    name
    |> safe_name
    |> IO.inspect
    |> GenServer.cast(arg)
  end
end
