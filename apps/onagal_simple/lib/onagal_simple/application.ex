defmodule OnagalSimple.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      OnagalSimple.Telemetry,
      # PubSub
      #{Phoenix.PubSub, name: Onagal.PubSub},
      # Start the Endpoint (http/https)
      OnagalSimple.Endpoint
      # Start a worker by calling: OnagalSimple.Worker.start_link(arg)
      # {OnagalSimple.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OnagalSimple.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OnagalSimple.Endpoint.config_change(changed, removed)
    :ok
  end
end
