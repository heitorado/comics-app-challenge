module Marvel
  class Character
    attr_accessor :id, :name, :thumbnail_urls

    def initialize(**attrs)
      @id = attrs[:id]
      @name = attrs[:name]
      @thumbnail_urls = attrs[:thumbnail_urls]
    end
  end
end