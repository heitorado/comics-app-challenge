module ComicsHelper
  def current_page
    @comics_service.current_page
  end

  def first_page?
    @comics_service.current_page == 1
  end

  def last_page?
    @comics_service.last_page == @comics_service.current_page
  end

  def user_favourite?(comic_id)
    !!@user.favourite_comics[comic_id.to_s]
  end
end
