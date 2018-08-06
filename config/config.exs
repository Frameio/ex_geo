use Mix.Config

config :ex_geo, ExGeo.Store,
  url: "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz",
  lookup_interval: 1000 * 60 * 60 * 24