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

  def favourite_comic
    @user.favourite_comics[params[:comic_id]] = true
    @user.save

    render json: { favourite_button: render_to_string('comics/_favourite_button', layout: false, locals: { user: @user, comic_id: params[:comic_id] }) }
  end

  def unfavourite_comic
    @user.favourite_comics.delete(params[:comic_id])
    @user.save

    render json: { favourite_button: render_to_string('comics/_favourite_button', layout: false, locals: { user: @user, comic_id: params[:comic_id] }) }
  end

  private 

  def comic_params
    params.permit(:page, :character_name_query, :commit)
  end
end
