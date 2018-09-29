defmodule GitExPress.MixProject do
  use Mix.Project

  def project do
    [
      app: :gitexpress,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_deps: :apps_direct, plt_add_apps: [:mnesia]],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {GitExPress.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:slugger, "~> 0.3.0"},
      {:earmark, "~> 1.2"},
      {:git_cli, "~> 0.2.5"},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:credo, "~> 0.10.2", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10.1", only: :test, runtime: false}
    ]
  end
end
