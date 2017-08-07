defmodule Dots.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(DotsWeb.Endpoint, []),
      supervisor(Dots, []),
    ]

    opts = [strategy: :one_for_one, name: Dots.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    DotsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
