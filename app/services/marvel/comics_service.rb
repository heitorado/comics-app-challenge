module Marvel
  class ComicsService
    def initialize
      @client = MarvelApi::V1::Client.new
    end

    def get_comics(page:, limit:)
      response_hash = @client.comics(page: page, limit: limit)

      comics_hash = response_hash.dig(:data, :results) || {}

      build_comics(comics_hash)
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

    def build_thumbnail_urls(thumbnail_hash)
      thumbnails = {}
      MarvelApi::V1::Client::THUMBNAIL_SIZES.each do |size, path_element|
        thumbnails[size] = "#{thumbnail_hash[:path]}/#{path_element}.#{thumbnail_hash[:extension]}"
      end

      thumbnails
    end
  end
end