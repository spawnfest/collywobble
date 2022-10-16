defmodule Core.MixProject do
  use Mix.Project

  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {Core.Application, []}
    ]
  end

  def project do
    [
      aliases: aliases(),
      app: :collywobble,
      compilers: Mix.compilers(),
      deps: deps(),
      dialyzer: dialyzer(),
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [credo: :test, dialyzer: :test],
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", runtime: false},
      {:dialyxir, "~> 1.2", runtime: false},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:floki, ">= 0.30.0", only: :test},
      {:gettext, "~> 0.18"},
      {:html_query, "~> 0.1", only: :test},
      {:jason, "~> 1.2"},
      {:moar, "~> 1.19"},
      {:mix_audit, "~> 2.0", runtime: false},
      {:pages, "~> 0.5", only: :test},
      {:phoenix, "~> 1.6.14"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.7"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.0"},
      {:plug_cowboy, "~> 2.5"},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"}
    ]
  end

  def dialyzer do
    [
      plt_add_apps: [:ex_unit, :inets, :mix],
      plt_add_deps: :app_tree,
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
