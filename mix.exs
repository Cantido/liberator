defmodule Liberator.MixProject do
  use Mix.Project

  def project do
    [
      app: :liberator,
      description: "An Elixir library for building controllers that obey the HTTP spec.",
      version: "1.0.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp package do
    [
      maintainers: ["Rosa Richter"],
      licenses: ["GPL v3"],
      links: %{"Github" => "https://github.com/Cantido/liberator"}
    ]
  end

  def docs do
    [
      main: "Liberator",
      source_url: "https://github.com/Cantido/liberator",
      extras: [
        "README.md"
      ]
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
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:timex, "~> 3.5"},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end
end
