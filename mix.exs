defmodule ExGeo.MixProject do
  use Mix.Project

  @version "1.2.0"

  def project do
    [
      app: :ex_geo,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ExGeo.Application, []}
    ]
  end

  defp deps do
    [
      {:mmdb2_decoder, "~> 0.3.0"},
      {:httpoison, "~> 1.2.0"},
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp docs() do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}",
      source_url: "https://github.com/Frameio/ex_geo"
    ]
  end

  defp description() do
    "A simple little genserver that keeps a maxmind geolocation database up to date"
  end

  defp package() do
    [
      maintainers: ["Michael Guarino"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Frameio/ex_geo"}
    ]
  end
end
