defmodule Weather.ParseData do
  @user_agent [{"User-agent", "Weather torleif@hawaii.edu"}]
  @noaa_url Application.get_env(:weather, :noaa_url)

  def fetch(loc_code) do
    weather_url(loc_code)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def weather_url(loc_code) do
    "#{@noaa_url}/#{loc_code}.xml"
  end

  def handle_response({:ok, %{status_code: 200, body: body }}) do
    { :ok, body }
  end

  def handle_response({_, %{status_code: _, body: body }}) do
    { :error, body }
  end
end
