use Mix.Config

config :ex_geo, ExGeo.Store,
  url: System.get_env("GEOLITE_URL"),
  helper: ExGeo.Downloader.MaxmindHelper,
  lookup_interval: 1000 * 60 * 60 * 24
