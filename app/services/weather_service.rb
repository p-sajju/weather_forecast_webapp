class WeatherService
  BASE_URL = 'https://api.open-meteo.com/v1/forecast'

  def initialize(lat, lon)
    @lat = lat
    @lon = lon
  end

  def forecast
    response = Faraday.get(BASE_URL, {
      latitude: @lat,
      longitude: @lon,
      current_weather: true,
      daily: 'temperature_2m_max,temperature_2m_min',
      timezone: 'auto'
    })

    raise 'Weather API error' unless response.success?

    data = JSON.parse(response.body)

    {
      current_temp: data.dig('current_weather', 'temperature'),
      high: data.dig('daily', 'temperature_2m_max')&.first,
      low: data.dig('daily', 'temperature_2m_min')&.first
    }
  end
end
