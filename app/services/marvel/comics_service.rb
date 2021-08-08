module Marvel
  class ComicsService
    def initialize
      @client = MarvelApi::V1::Client.new
    end

    def get_comics(page:, **opts)
      limit = opts[:limit] || MarvelApi::V1::Client::DEFAULT_ITEMS_PER_PAGE
      response_hash = @client.comics(page: page, limit: limit, **opts)

      comics_hash = response_hash.dig(:data, :results) || {}

      build_comics(comics_hash)
    end

    def get_characters(page:, **opts)
      limit = opts[:limit] || MarvelApi::V1::Client::DEFAULT_ITEMS_PER_PAGE
      response_hash = @client.characters(page: page, limit: limit, **opts)

      characters_hash = response_hash.dig(:data, :results) || {}

      build_characters(characters_hash)
    end

    private

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