# SPDX-FileCopyrightText: 2024 Rosa Richter
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule Liberator.MixProject do
  use Mix.Project

  def project do
    [
      app: :liberator,
      description: "An Elixir library for building controllers that obey the HTTP spec.",
      package: package(),
      docs: docs(),
      version: "2.0.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp package do
    [
      maintainers: ["Rosa Richter"],
      licenses: ["AGPL-3.0-or-later", "CC-BY-4.0", "CC0-1.0"],
      links: %{
        "GitHub" => "https://github.com/Cantido/liberator",
        "sourcehut" => "https://sr.ht/~cosmicrose/liberator",
        "Sponsor" => "https://liberapay.com/rosa"
      }
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
        "SECURITY.md",
        "code_of_conduct.md",
        "guides/getting_started.md",
        "guides/decision_tree.md"
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
          Liberator.MediaType.TextPlain
        ],
        Debugging: [
          Liberator.Trace
        ],
        Exceptions: [
          Liberator.InvalidLastModifiedValueException,
          Liberator.InvalidRetryAfterValueException,
          Liberator.CompressionCodecInvalidResultException,
          Liberator.CompressionCodecNotFoundException,
          Liberator.MediaTypeCodecInvalidResultException,
          Liberator.MediaTypeCodecNotFoundException,
          Liberator.UnknownStepException
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
      {:plug, "~> 1.0"},
      {:gettext, "~> 0.26.0"},
      {:jason, "~> 1.2"},
      {:telemetry, "~> 1.0"},
      {:telemetry_registry, "~> 0.3"},
      {:timex, "~> 3.6"},
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:hex_licenses, "~> 0.3.0", only: :dev, runtime: false},
      {:sobelow, "~> 0.8", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end
end
