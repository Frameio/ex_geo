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
    {:ok, []}
  end

  @doc """
  Fetches the current geo db
  """
  @spec fetch() :: {:ok, MMDB2Decoder.parse_result} | {:error, :download_error}
  def fetch(), do: GenServer.call(__MODULE__, :db)

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
  def query(ip), do: GenServer.call(__MODULE__, {:query, ip})

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

  def handle_call(_, _from, {:invaliddb, reason} = state), do: {:reply, {:error, reason}, state}
  def handle_call({:query, ip}, _from, state) do
    MMDB2Decoder.pipe_lookup(state, ip)
    |> query_result(state)
  end
  def handle_call(:db, _from, state), do: {:reply, {:ok, state}, state}

  def handle_info(:download, _) do
    schedule_download()

    Downloader.download!(@url)
    |> :zlib.gunzip()
    |> MMDB2Decoder.parse_database()
    |> store()
  end

  defp query_result(nil, state), do: {:reply, {:error, :not_found}, state}
  defp query_result(result, state), do: {:reply, {:ok, result}, state}

  defp store({_meta, _tree, _data} = result), do: {:noreply, result}
  defp store(_), do: {:noreply, {:invaliddb, :download_error}}

  defp schedule_download(duration \\ @day), do: Process.send_after(self(), :download, duration)
end