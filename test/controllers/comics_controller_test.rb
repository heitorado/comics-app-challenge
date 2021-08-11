require "test_helper"

class ComicsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @comics_service = Marvel::ComicsService.new
    Marvel::ComicsService.expects(:new).returns(@comics_service).at_most(1)
  end

  test "should get index as root url" do
    @comics_service.expects(:get_comics)

    get root_url
    assert_response :success
  end

  test "should get search_by_character" do
    @comics_service.expects(:get_characters)
    @comics_service.expects(:get_comics).at_most(1)

    get search_by_character_url(character_name_query: 'some character')
    assert_response :success
  end

  test "should post favourite_comic" do
    post favourite_comic_url(comic_id: '123')
    assert_response :success
  end

  test "should post unfavourite_comic" do
    post unfavourite_comic_url(comic_id: '123')
    assert_response :success
  end

  test "should call the appropriate service method on index" do
    comics_service = Marvel::ComicsService.new
    Marvel::ComicsService.expects(:new).returns(comics_service)
    comics_service.expects(:get_characters).once

    get search_by_character_url(page: 1, character_name_query: 'some character')
  end

  test "should query for comics if at least one character was found" do
    comics_service = Marvel::ComicsService.new
    Marvel::ComicsService.expects(:new).returns(comics_service)
    comics_service.expects(:get_characters).with(page: 1, name_starts_with: 'some character').returns([Marvel::Character.new]).once
    comics_service.expects(:get_comics).once

    get search_by_character_url(page: 1, character_name_query: 'some character')
  end

  test "should not query for comics if no characters were found" do
    comics_service = Marvel::ComicsService.new
    Marvel::ComicsService.expects(:new).returns(comics_service)
    comics_service.expects(:get_characters).with(page: 1, name_starts_with: 'some character').returns([]).once
    comics_service.expects(:get_comics).never

    get search_by_character_url(page: 1, character_name_query: 'some character')
  end

  test "should return a JSON via AJAX when favouriting a comic" do
    post favourite_comic_url(comic_id: '123'), xhr: true

    assert_equal 'application/json', @response.media_type
  end

  test "should return a JSON via AJAX when unfavouriting a comic" do
    post unfavourite_comic_url(comic_id: '123'), xhr: true

    assert_equal 'application/json', @response.media_type
  end
end
