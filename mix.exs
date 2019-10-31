defmodule CNPJ.MixProject do
  use Mix.Project

  def project do
    [
      app: :cnpj,
      version: "0.0.0",
      elixir: "~> 1.6",
      package: package(),
      description: description(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def description do
    "A Brazilian CNPJ validation written in Elixir."
  end

  def package do
    [
      name: "cnpj",
      maintainers: ["Ulisses Almeida"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ulissesalmeida/cnpj"}
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
      {:ex_doc, only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
