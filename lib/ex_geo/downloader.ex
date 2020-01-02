defmodule ExGeo.Downloader do
  defmodule DownloadError do
    defexception message: "could not download"
  end

  @doc """
  Downloads the contents of `url` with up to 3 retries
  """
  @spec download!(binary) :: binary
  def download!(url, retry \\ 1)
  def download!(_, retry) when retry >= 3, do: raise(DownloadError, message: "retries exceeded")

  def download!(url, retry) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body
      _ -> download!(url, retry + 1)
    end
  end
end

defmodule ExGeo.Downloader.MaxmindHelper do
  def handle(data) do
    unzipped = :zlib.gunzip(data)
    {:ok, contents} = :erl_tar.extract({:binary, unzipped}, [:memory])

    {_, db} =
      Enum.find(contents, fn {filename, _} ->
        filename
        |> List.to_string()
        |> String.ends_with?(".mmdb")
      end)

    db
  end
end
