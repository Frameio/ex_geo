defmodule ExGeo.StoreTest do
  use ExUnit.Case
  describe "#fetch/0" do
    test "It will fetch a recent maxmind database" do
      :timer.sleep(1000)
      {:ok, db} = ExGeo.Store.fetch()

      assert tuple_size(db) == 3
    end
  end
end