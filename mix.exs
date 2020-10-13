defmodule Liberator.MixProject do
  use Mix.Project

  def project do
    [
      app: :liberator,
      description: "An Elixir library for building controllers that obey the HTTP spec.",
      package: package(),
      docs: docs(),
      version: "1.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp package do
    [
      maintainers: ["Rosa Richter"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/Cantido/liberator"}
    ]
  end

  def docs do
    [
      main: "Liberator.Resource",
      source_url: "https://github.com/Cantido/liberator",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "CONTRIBUTING.md",
        "code_of_conduct.md"
      ],
      groups_for_modules: [
        # Ungrouped:
        #
        # Liberator
        # Liberator.Evaluator
        # Liberator.Resource

        "Content Negotiation": [
          Liberator.Codec,
          Liberator.ContentNegotiation,
          Liberator.Encoding.Deflate,
          Liberator.Encoding.Gzip,
          Liberator.Encoding.Identity,
          Liberator.MediaType.TextPlainCodec,
        ],
        "Debugging": [
          Liberator.Trace
        ]
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
      {:credo, "~> 1.5.0-rc.2", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end
end
