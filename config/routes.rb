Rails.application.routes.draw do
  # Show the form to enter address or zip code
  root "forecasts#index"

  # POST: Submit address to fetch forecast
  post "forecast", to: "forecasts#forecast", as: :fetch_forecast

  # GET: Show the forecast result after redirect
  get "forecast/result", to: "forecasts#show_forecast", as: :forecast_result
end
