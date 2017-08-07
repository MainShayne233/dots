defmodule DotsWeb.UserSocket do
  use Phoenix.Socket

  channel "dot:*", DotsWeb.DotChannel

  transport :websocket, Phoenix.Transports.WebSocket

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
