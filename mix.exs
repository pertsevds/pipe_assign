# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 Dmitriy Pertsev

defmodule PipeAssign.MixProject do
  use Mix.Project

  def project do
    [
      app: :pipe_assign,
      version: "2.0.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      docs: docs(),
      aliases: aliases(),
      test_coverage: test_coverage(),
      deps: deps()
    ]
  end

  defp elixirc_paths(:dev), do: ["lib", "mix"]
  defp elixirc_paths(_), do: ["lib"]

  def test_coverage do
    [
      summary: [threshold: 90],
      ignore_modules: []
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # extra_applications: [:logger]
    ]
  end

  defp description do
    "PipeAssign provides a macro for capturing intermediate values in Elixir pipe chains without breaking the flow or requiring separate assignment statements."
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/pertsevds/pipe_assign"},
      files: ["lib", "mix.exs", "README.md", "LICENSE", "NOTICE"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4", only: [:dev, :test]},
      {:styler, "~> 1.4", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true},
      {:benchee, "~> 1.3", only: :dev, runtime: false},
      {:benchee_html, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "LICENSE",
        "NOTICE"
      ]
    ]
  end

  defp aliases do
    [
      test: "test --warnings-as-errors"
    ]
  end
end
