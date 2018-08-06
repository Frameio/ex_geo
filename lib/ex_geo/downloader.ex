defmodule ExGeo.Downloader do
  defmodule DownloadError do
    defexception message: "could not download"
  end

  @doc """
  Downloads the contents of `url` with up to 3 retries
  """
  @spec download!(binary) :: binary
  def download!(url, retry \\ 1)
  def download!(_, retry) when retry >= 3, do: raise DownloadError, message: "retries exceeded"
  def download!(url, retry) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body
      _ -> download!(url, retry + 1)
    end
  end
end