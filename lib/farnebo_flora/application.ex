defmodule FarneboFlora.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FarneboFloraWeb.Telemetry,
      FarneboFlora.Repo,
      {DNSCluster, query: Application.get_env(:farnebo_flora, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FarneboFlora.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: FarneboFlora.Finch},
      # Start a worker by calling: FarneboFlora.Worker.start_link(arg)
      # {FarneboFlora.Worker, arg},
      # Start to serve requests, typically the last entry
      FarneboFloraWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FarneboFlora.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FarneboFloraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
