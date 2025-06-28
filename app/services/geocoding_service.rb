class GeocodingService
  def initialize(address)
    @address = address
  end

  def coordinates
    result = Geocoder.search(@address).first
    raise 'Address not found' unless result
    [result.latitude, result.longitude, result.postal_code || @address]
  end
end
