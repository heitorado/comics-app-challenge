class ComicsController < ApplicationController
  def index
    comics_service = Marvel::ComicsService.new
    @comics = comics_service.get_comics(page: comic_params[:page].to_i, limit: 100)
  end

  private 

  def comic_params
    params.permit(:page)
  end
end
