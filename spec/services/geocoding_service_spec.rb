require 'rails_helper'

RSpec.describe GeocodingService do
  describe '#coordinates' do
    let(:address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
    subject { described_class.new(address) }

    context 'when address is found' do
      let(:mock_result) do
        double('GeocoderResult',
          latitude: 37.422,
          longitude: -122.084,
          postal_code: '94043'
        )
      end

      before do
        allow(Geocoder).to receive(:search).with(address).and_return([mock_result])
      end

      it 'returns the latitude, longitude, and postal code' do
        expect(subject.coordinates).to eq([37.422, -122.084, '94043'])
      end
    end

    context 'when address is found but postal code is nil' do
      let(:mock_result) do
        double('GeocoderResult',
          latitude: 37.422,
          longitude: -122.084,
          postal_code: nil
        )
      end

      before do
        allow(Geocoder).to receive(:search).with(address).and_return([mock_result])
      end

      it 'returns latitude, longitude, and the original address' do
        expect(subject.coordinates).to eq([37.422, -122.084, address])
      end
    end

    context 'when address is not found' do
      before do
        allow(Geocoder).to receive(:search).with(address).and_return([])
      end

      it 'raises an error' do
        expect { subject.coordinates }.to raise_error('Address not found')
      end
    end
  end
end
