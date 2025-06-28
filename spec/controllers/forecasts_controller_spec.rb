require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do
  let(:address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
  let(:lat) { 37.422 }
  let(:lon) { -122.084 }
  let(:zip) { '94043' }
  let(:forecast_data) do
    {
      "current_temp" => 20.5,
      "high" => 25.0,
      "low" => 15.0,
      "from_cache" => false
    }
  end

  before do
    # Stub GeocodingService to return fixed coordinates
    allow_any_instance_of(GeocodingService).to receive(:coordinates).and_return([lat, lon, zip])
  end

  describe 'POST #forecast' do
    context 'when address is blank' do
      it 'redirects to root with alert' do
        post :forecast, params: { address: '' }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Please enter an address or ZIP code.')
      end
    end

    context 'when forecast is not cached' do
      before do
        # Make sure Redis does not have cache
        allow($redis).to receive(:get).and_return(nil)
        allow($redis).to receive(:setex)
        # Stub WeatherService to return forecast_data
        allow_any_instance_of(WeatherService).to receive(:forecast).and_return(forecast_data.except("from_cache"))
      end

      it 'fetches forecast, caches it, and redirects' do
        post :forecast, params: { address: address }

        expect($redis).to have_received(:setex).with("forecast_#{zip}", anything, kind_of(String))
        expect(response).to redirect_to(forecast_result_path(zip: zip))
        expect(flash[:alert]).to be_nil
      end
    end

    context 'when forecast is cached' do
      before do
        cached_json = forecast_data.merge("from_cache" => true).to_json
        allow($redis).to receive(:get).and_return(cached_json)
      end

      it 'uses cached forecast and redirects' do
        post :forecast, params: { address: address }

        expect(response).to redirect_to(forecast_result_path(zip: zip))
        expect(flash[:alert]).to be_nil
      end
    end

    context 'when an error occurs' do
      before do
        allow_any_instance_of(GeocodingService).to receive(:coordinates).and_raise("Geocode failure")
      end

      it 'redirects to root with error alert' do
        post :forecast, params: { address: address }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Error: Geocode failure")
      end
    end
  end

  describe 'GET #show_forecast' do

    context 'when cache is missing' do
      before do
        allow(Rails.cache).to receive(:read).with("forecast_result_#{zip}").and_return(nil)
      end

      it 'redirects to root with alert' do
        get :show_forecast, params: { zip: zip }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Forecast expired or not found. Please search again.")
      end
    end
  end
end
