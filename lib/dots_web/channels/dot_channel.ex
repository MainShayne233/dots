defmodule DotsWeb.DotChannel do
  use Phoenix.Channel

  def join("dot:channel", _params, socket) do
    {:ok, socket}
  end

  def handle_in("dot:init", _params, socket) do
    Dots.tell_clients_about_yourself()
    {:noreply, socket}
  end
end
