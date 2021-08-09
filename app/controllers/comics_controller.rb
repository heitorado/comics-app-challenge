class ComicsController < ApplicationController
  def index
    @comics_service = Marvel::ComicsService.new
    @comics = @comics_service.get_comics(page: comic_params[:page].to_i)
  end

  def search_by_character
    redirect_to root_path and return if comic_params[:character_name_query].blank?

    @comics_service = Marvel::ComicsService.new
    characters = @comics_service.get_characters(page: comic_params[:page].to_i, name_starts_with: comic_params[:character_name_query])
    @comics = @comics_service.get_comics(page: comic_params[:page].to_i, character_ids: characters.map(&:id))

    render :index
  end

  private 

  def comic_params
    params.permit(:page, :character_name_query, :commit)
  end
end
