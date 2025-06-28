require 'rails_helper'
require 'webmock/rspec'

RSpec.describe WeatherService do
  let(:lat) { 37.7749 }
  let(:lon) { -122.4194 }
  let(:service) { described_class.new(lat, lon) }

  let(:api_url) {
    "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&current_weather=true&daily=temperature_2m_max,temperature_2m_min&timezone=auto"
  }

  let(:fake_response) {
    {
      current_weather: {
        temperature: 22.5
      },
      daily: {
        temperature_2m_max: [30.1],
        temperature_2m_min: [15.2]
      }
    }.to_json
  }

  before do
    stub_request(:get, api_url)
      .to_return(status: 200, body: fake_response, headers: { 'Content-Type' => 'application/json' })
  end

  describe '#forecast' do
    it 'returns current, high, and low temperature' do
      result = service.forecast

      expect(result).to eq({
        current_temp: 22.5,
        high: 30.1,
        low: 15.2
      })
    end
  end

  context 'when API returns an error' do
    before do
      stub_request(:get, api_url).to_return(status: 500)
    end

    it 'raises an error' do
      expect { service.forecast }.to raise_error('Weather API error')
    end
  end
end
