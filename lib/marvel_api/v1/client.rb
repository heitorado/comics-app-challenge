require 'rest-client'

module MarvelApi
  module V1
    class Client
      include MarvelApi::V1::AllowedParameterValues

      DEFAULT_SORT_PARAMETER = SORT_PARAMETER[:on_sale_date]
      DEFAULT_SORT_DIRECTION = SORT_DIRECTION[:desc]
      DEFAULT_FORMAT_TYPE = FORMAT_TYPE[:comic]
      DEFAULT_ITEMS_PER_PAGE = 100
      MAX_ALLOWED_CHARACTER_IDS = 10

      def initialize
        @api_url = Rails.application.credentials.marvel_api[:url]
        @credentials = build_credentials
      end

      def comics(page:, limit: DEFAULT_ITEMS_PER_PAGE, **opts)
        page = validate_page(page)
        limit = validate_limit(limit)
        
        sort_parameter = opts[:sort_parameter] || DEFAULT_SORT_PARAMETER
        sort_direction = opts[:sort_direction] || DEFAULT_SORT_DIRECTION
        format_type = opts[:format_type] || DEFAULT_FORMAT_TYPE
        no_variants = opts[:no_variants].present? ? opts[:no_variants] : true
        character_ids = opts[:character_ids] ||  nil

        parse(
          get(
            'comics',
            {
              limit: limit, 
              offset: (page - 1) * limit, 
              orderBy: "#{sort_direction}#{sort_parameter}", 
              formatType: format_type, 
              noVariants: no_variants,
              dateRange: ",#{Time.current.strftime('%Y-%m-%d')}",
              characters: character_ids&.first(MAX_ALLOWED_CHARACTER_IDS)&.join(',')
            }.compact
          ).body
        )
      end

      def characters(page:, limit: DEFAULT_ITEMS_PER_PAGE, **opts)
        page = validate_page(page)
        limit = validate_limit(limit)

        name_starts_with = opts[:name_starts_with].present? ? opts[:name_starts_with] : nil

        parse(
          get(
            'characters',
            {
              limit: limit, 
              offset: (page - 1) * limit, 
              nameStartsWith: name_starts_with
            }.compact
          ).body
        )
      end

      private

      def validate_page(page)
        return 1 if page < 1
        page
      end

      def validate_limit(limit)
        return DEFAULT_ITEMS_PER_PAGE if limit > DEFAULT_ITEMS_PER_PAGE || limit < 1
        limit
      end

      def parse(body)
        JSON.parse(body, symbolize_names: true)
      end

      def get(route, params = {})
        RestClient.get("#{@api_url}/#{route}?#{@credentials}&#{build_params(params)}")
      rescue RestClient::Exception => e
        # Log the response and return empty JSON
        Rails.logger.error e.response
        '{}'
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