require 'httparty'
require 'json'

def convert_geoip_boolean(value)
  value == 'yes' ? true : false
end

def lambda_handler(event:, context:)
  sourceIp = event['requestContext']['identity']['sourceIp']
  certPath = './cosmos/cert.pem'

  options = {
    pem: File.read(certPath),
    verify: false
  }

  begin
    response = HTTParty.head("https://geoip.test.tools.bbc.co.uk/#{sourceIp}", options)

    uk_combined = convert_geoip_boolean(response.headers['x-ip_is_uk_combined']);
    advertise_combined = convert_geoip_boolean(response.headers['x-ip_is_advertise_combined']);
    country_code = response.headers['x-country'];
  rescue HTTParty::Error => error
    puts error.inspect
    raise error
  end

  return {
    :statusCode => response.code,
    :body => {
      :geoip => {
        uk_combined: uk_combined,
        advertise_combined: advertise_combined,
        country_code: country_code
      }
    }.to_json
  }
end
