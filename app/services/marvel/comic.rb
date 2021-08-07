module Marvel
  class Comic
    attr_accessor :id, :title, :thumbnail_urls

    def initialize(**attrs)
      @id = attrs[:id]
      @title = attrs[:title]
      @thumbnail_urls = attrs[:thumbnail_urls]
    end
  end
end