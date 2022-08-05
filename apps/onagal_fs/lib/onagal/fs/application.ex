defmodule Onagal.Fs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    watch_dir = Application.get_env(:onagal_fs, Onagal.Fs)[:watch_dir]

    children = [
      # Starts a worker by calling: Onagal.Fs.Watch.Worker.start_link(arg)
      # {Onagal.Fs.Watch.Worker, arg}
      {Onagal.Fs, dirs: [watch_dir]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Onagal.Fs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
