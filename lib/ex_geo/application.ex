defmodule ExGeo.Application do
  use Application
  import Supervisor.Spec

  def start(_, _) do
    children = [
      worker(ExGeo.Store, [])
    ]

    opts = [strategy: :one_for_one, name: ExGeo.Application.Supervisor]
    Supervisor.start_link(children, opts)
  end
end