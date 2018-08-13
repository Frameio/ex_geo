defmodule ExGeo.Store do
  @moduledoc """
  Genserver responsible for storing and syncing the maxmind2 geolocation db
  """
  use GenServer
  alias ExGeo.Downloader

  defmodule Exception do
    defexception message: "Failed to get db"
  end

  @config Application.get_env(:ex_geo, __MODULE__)
  @day @config[:lookup_interval]
  @url @config[:url]

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    send(self(), :download)
    {:ok, :ets.new(:exgeo_store, [:named_table, :set, :protected, read_concurrency: true])}
  end

  @doc """
  Fetches the current geo db
  """
  @spec fetch() :: {:ok, MMDB2Decoder.parse_result} | {:error, :download_error}
  def fetch() do
    case :ets.lookup(:exgeo_store, :db) do
      [{:db, db}] -> {:ok, db}
      _ -> {:error, :download_error}
    end
  end

  @doc """
  Same as fetch but throws if not found
  """
  @spec fetch!() :: MMDB2Decoder.parse_result
  def fetch!() do
    case fetch() do
      {:ok, db} -> db
      _ -> raise Exception, message: "Could not find database"
    end
  end

  @doc """
  Queries the stored maxmind database and returns a raw result if found.  Fails if
  the db failed to download
  """
  @spec query(ExGeo.ip_address) :: {:ok, map} | {:error, :download_error | :not_found}
  def query(ip) do
    with {:ok, db} <- fetch() do
      MMDB2Decoder.pipe_lookup(db, ip)
      |> query_result()
    end
  end

  @doc """
  Same as `query/1` except will throw an `Exception.t` if no db has been downloaded
  """
  @spec query!(ExGeo.ip_address) :: map
  def query!(ip) do
    case query(ip) do
      {:ok, result} -> result
      {:error, :not_found} -> raise Exception, message: "Could not locate: #{inspect(ip)}"
      _ -> raise Exception, message: "Could not find database"
    end
  end

  def handle_info(:download, table) do
    schedule_download()

    Downloader.download!(@url)
    |> :zlib.gunzip()
    |> MMDB2Decoder.parse_database()
    |> store(table)
  end

  defp query_result(nil), do: {:error, :not_found}
  defp query_result(result), do: {:ok, result}

  defp store({_meta, _tree, _data} = result, table) do
    :ets.insert(table, {:db, result})
    {:noreply, table}
  end
  defp store(_, table), do: {:noreply, table}

  defp schedule_download(duration \\ @day), do: Process.send_after(self(), :download, duration)
end