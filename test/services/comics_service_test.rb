require "test_helper"

class ComicsServiceTest < ActiveSupport::TestCase
  def setup
    @api_client = MarvelApi::V1::Client.new
    MarvelApi::V1::Client.expects(:new).returns(@api_client)
    @comics_service = Marvel::ComicsService.new

    @comics_data = { data: { offset: 0, total: 3, limit: 100, results: [{ id: '1', title: 'Comic 1',  thumbnail: { path: '/path/to/thumbnail1', extension: 'png'} }, { id: '2', title: 'Comic 2',  thumbnail: { path: '/path/to/thumbnail2', extension: 'png'} }] } }
    @characters_data = { data: { offset: 0, total: 3, limit: 100, results: [{ id: '1', name: 'Character 1',  thumbnail: { path: '/path/to/thumbnail1', extension: 'png'} }, { id: '2', name: 'Character 2',  thumbnail: { path: '/path/to/thumbnail2', extension: 'png'} }] } }
  end

  test "#get_comics should return an array of Comics" do
    @api_client.expects(:comics).returns(@comics_data)

    comics = @comics_service.get_comics(page: 1)

    assert_equal 2, comics.count
    assert_equal Array, comics.class
  end
  
  test "#get_comics should always try to use data from cache first" do
    Rails.cache.expects(:fetch).once.returns(@comics_data)

    @comics_service.get_comics(page: 1)
  end

  test "#get_characters should return an array of Characters" do
    @api_client.expects(:characters).returns(@characters_data)

    characters = @comics_service.get_characters(page: 1)

    assert_equal 2, characters.count
    assert_equal Array, characters.class
  end

  test "#get_characters should always try to use data from cache first" do
    Rails.cache.expects(:fetch).once.returns(@characters_data)

    @comics_service.get_characters(page: 1)
  end
end
