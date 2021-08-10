module Marvel
  class ComicsService
    attr_reader :current_page, :last_page

    def initialize
      @client = MarvelApi::V1::Client.new
      @current_page = nil
      @last_page = nil
    end

    def get_comics(page:, **opts)
      limit = opts[:limit] || MarvelApi::V1::Client::DEFAULT_ITEMS_PER_PAGE

      response_hash = 
        Rails.cache.fetch("#{page}#{limit}#{opts}/comics", expires_in: 15.minutes) do
          @client.comics(page: page, limit: limit, **opts)
        end

      set_pagination_info(response_hash)
      comics_hash = response_hash.dig(:data, :results) || {}
      build_comics(comics_hash)
    end

    def get_characters(page:, **opts)
      limit = opts[:limit] || MarvelApi::V1::Client::DEFAULT_ITEMS_PER_PAGE
      
      response_hash = 
        Rails.cache.fetch("#{page}#{limit}#{opts}/characters", expires_in: 15.minutes) do
          response_hash = @client.characters(page: page, limit: limit, **opts)
        end

      set_pagination_info(response_hash)
      characters_hash = response_hash.dig(:data, :results) || {}
      build_characters(characters_hash)
    end

    private

    def set_pagination_info(response_hash)
      current_offset = response_hash.dig(:data, :offset) || 0
      total_records = response_hash.dig(:data, :total) || 0
      record_limit = response_hash.dig(:data, :limit) || 0

      # We add 1 to each page value because the API offset pagination makes it zero based,
      # but the controller uses page numbers starting from 1.
      @current_page = (current_offset / (record_limit.nonzero? || 1)).ceil + 1
      @last_page = (total_records / (record_limit.nonzero? || 1)).floor + 1
    end

    def build_comics(comics_hash)
      comics_hash.map do |comic|
        Comic.new(
          id: comic[:id],
          title: comic[:title],
          thumbnail_urls: build_thumbnail_urls(comic[:thumbnail])
        )
      end
    end

    def build_characters(characters_hash)
      characters_hash.map do |character|
        Character.new(
          id: character[:id],
          name: character[:name],
          thumbnail_urls: build_thumbnail_urls(character[:thumbnail])
        )
      end
    end

    def build_thumbnail_urls(thumbnail_hash)
      thumbnails = {}
      MarvelApi::V1::Client::THUMBNAIL_SIZES.each do |size, path_element|
        thumbnails[size] = "#{thumbnail_hash[:path]}/#{path_element}.#{thumbnail_hash[:extension]}"
      end

      thumbnails
    end
  end
end