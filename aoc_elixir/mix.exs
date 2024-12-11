defmodule AocElixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aoc_elixir,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:json, "~> 1.4.1"},
      {:libgraph, "~> 0.16.0"},
      {:comb, git: "https://github.com/tallakt/comb.git", tag: "master"},
      {:memoize, "~> 1.4"}
    ]
  end
end
