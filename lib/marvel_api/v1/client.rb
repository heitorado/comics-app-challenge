require 'rest-client'

module MarvelApi
  module V1
    class Client
      include MarvelApi::V1::ParameterValues

      DEFAULT_SORT_PARAMETER = SORT_PARAMETER[:on_sale_date]
      DEFAULT_SORT_DIRECTION = SORT_DIRECTION[:desc]
      DEFAULT_FORMAT_TYPE = FORMAT_TYPE[:comic]
      DEFAULT_COMICS_PER_PAGE = 100

      def initialize
        @api_url = Rails.application.credentials.marvel_api[:url]
        @credentials = build_credentials
      end

      def comics(page:, limit: MAX_COMICS_PER_PAGE)
        limit = limit > MAX_COMICS_PER_PAGE ? MAX_COMICS_PER_PAGE : limit
        page = page < 1 ? 1 : page

        parse(
          get('/comics', limit: limit, offset: (page - 1) * limit).body
        )
      end

      private

      def parse(body)
        JSON.parse(body, symbolize_names: true)
      end

      def get(route, params = {})
        RestClient.get("#{@api_url}/#{route}?#{@credentials}&#{build_params(params)}")
      end

      def build_credentials
        timestamp = Time.current.to_i.to_s
        hashed_credentials = 
          Digest::MD5.hexdigest(
            timestamp +
            Rails.application.credentials.marvel_api[:private_key] + 
            Rails.application.credentials.marvel_api[:public_key]
          )

        "ts=#{timestamp}&apikey=#{Rails.application.credentials.marvel_api[:public_key]}&hash=#{hashed_credentials}"
      end

      def build_params(params)
        params.map{ |param, val| "#{param}=#{val}" }.join('&') 
      end
    end
  end
end