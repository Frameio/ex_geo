defmodule ExGeo do
  @moduledoc """
  IP geolocation.  Simply call `ExGeo.lookup(ip)` to fetch a `ExGeo.Store.t` struct of
  various geographic data for an ip.
  """
  alias ExGeo.{
    Store,
    Result
  }

  defmodule InvalidIpError do
    defexception message: "invalid ip address"
  end

  @type ipv4 :: {integer, integer, integer, integer}
  @type ipv6 :: {integer, integer, integer, integer, integer, integer, integer, integer}
  @type ip_address :: ipv4 | ipv6

  defguardp is_ip_address(ip) when is_tuple(ip) and (tuple_size(ip) == 4 or tuple_size(ip) == 8)

  @doc """
  Looks up geolocation information for a binary or tuple ip
  """
  @spec lookup(binary | ip_address) :: {:ok, Result.t} | {:error, any}
  def lookup(ip) when is_binary(ip) do
    String.to_charlist(ip)
    |> :inet.parse_address()
    |> case do
      {:ok, ip} -> lookup(ip)
      error -> error
    end
  end
  def lookup(ip) when is_ip_address(ip) do
    with {:ok, query_result} <- Store.query(ip),
      do: {:ok, Result.parse(query_result)}
  end

  @doc """
  Same as `lookup/1` but raises an `InvalidIpError` if the ip cannot be parsed or queried
  """
  @spec lookup!(binary | ip_address) :: Result.t
  def lookup!(ip) do
    case lookup(ip) do
      {:ok, result} -> result
      _ -> raise InvalidIpError, message: "Could not lookup: #{inspect(ip)}"
    end
  end
end
