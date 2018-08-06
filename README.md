# ExGeo

A simple little genserver that keeps a maxmind geolocation database up to date

## Installation

```elixir
def deps do
  [
    {:ex_geo, "~> 1.1.0"}
  ]
end
```

## Usage

Usage is quite simple, as the underlying GenServer is started with the application:

```elixir
result = ExGeo.lookup(ip)

# result.country
# result.city
# result.postal
# result.region
# result.continent
```

The lookup is done against MaxMind's free [GeoLite2 City database](http://dev.maxmind.com/geoip/geoip2/geolite2/). If you want to bring your own geolocation db, you can tune these params:

```elixir
config :ex_geo, ExGeo.Store,
  url: "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz",
  lookup_interval: 1000 * 60 * 60 * 24
```
