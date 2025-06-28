class ForecastsController < ApplicationController
  def index
    # Displays the form
  end

  def forecast
    address = params[:address]
    if address.blank?
      flash[:alert] = "Please enter an address or ZIP code."
      return redirect_to root_path
    end

    lat, lon, zip = GeocodingService.new(address).coordinates
    cache_key = "forecast_#{zip}"

    if (cached = $redis.get(cache_key))
      @forecast = JSON.parse(cached).merge("from_cache" => true)
    else
      data = WeatherService.new(lat, lon).forecast
      @forecast = data.merge("from_cache" => false)
      $redis.setex(cache_key, 30.minutes.to_i, @forecast.to_json)
    end

    Rails.cache.write("forecast_result_#{zip}", { forecast: @forecast, address: address }, expires_in: 30.minutes)
    redirect_to forecast_result_path(zip: zip)
  rescue => e
    flash[:alert] = "Error: #{e.message}"
    redirect_to root_path
  end

  def show_forecast
    zip = params[:zip]
    cached = Rails.cache.read("forecast_result_#{zip}")

    unless cached
      flash[:alert] = "Forecast expired or not found. Please search again."
      return redirect_to root_path
    end

    @forecast = cached[:forecast]
    @address = cached[:address]
  end
end
