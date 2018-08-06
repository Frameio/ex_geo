defmodule ExGeo.Result do
  @moduledoc """
  Geolocation query result structure
  """
  @fields [
    :city,
    :continent,
    :country,
    :location,
    :postal,
    :region
  ]

  @type t :: %__MODULE__{}

  defstruct @fields

  @doc """
  Accepts a raw query result and returns a new `ExGeo.Result.t`
  """
  @spec parse(map) :: t
  def parse(result) when is_map(result) do
    struct(__MODULE__, Enum.into(@fields, %{}, & {&1, parse_field(result, &1)}))
  end

  defp parse_field(%{city: %{names: %{en: name}}}, :city), do: name
  defp parse_field(%{continent: %{code: name}}, :continent), do: name
  defp parse_field(%{country: %{iso_code: name}}, :country), do: name
  defp parse_field(%{location: loc}, :location), do: loc
  defp parse_field(%{postal: %{code: code}}, :postal), do: code
  defp parse_field(%{subdivisions: [%{iso_code: code} | _]}, :region), do: code
  defp parse_field(_, _), do: nil
end