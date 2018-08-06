defmodule ExGeoTest do
  use ExUnit.Case
  doctest ExGeo

  describe "#lookup!/1" do
    test "It will lookup geolocation data" do
      :timer.sleep(1000)
      %ExGeo.Result{} = result = ExGeo.lookup!("2604:2000:f88d:1b00:6963:5e5e:61bc:8426")

      assert result.city == "New York"
      assert result.continent == "NA"
      assert result.country == "US"
      assert is_map(result.location)
      assert result.postal == "10023"
      assert result.region == "NY"
    end

    test "It will raise on invalid ips" do
      assert_raise ExGeo.InvalidIpError, fn ->
        ExGeo.lookup!("invalid.ip")
      end
    end
  end
end
