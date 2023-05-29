defmodule MetexJoe.Worker do
  # apikey = 57ec128e180737fdbe33736eff511b7b


  def loop do
    receive do
      {sender_pid, location} ->
        IO.puts('working on #{location}')
        send(sender_pid, {:ok, temperature_of(location)})
      _ ->
        IO.puts('Unable to process message')
    end
    loop()

  end

  def temperature_of(location) do
    result = url_for(location) |> HTTPoison.get |> parse_response
    case result do
      {:ok, temp} ->
        IO.puts('returning #{location}')

        "#{location}:  #{temp}°C"
      :error ->
        "#{location} not found"
    end
  end

  # defp get_lat_long(location) do
  #   location = URI.encode(location)
  #   ""
  # end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> compute_temp
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temp(json) do
    try do
      temp = (json["main"]["temp"] - 273.15 |> Float.round(1))
      {:ok, temp}
    rescue
       _ -> :error
    end
  end

  defp apikey do
    "57ec128e180737fdbe33736eff511b7b"
  end

end
