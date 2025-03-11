# app/controllers/genres_controller.rb
class GenresController < ApplicationController
    def index
      genres = Genre.all.sort_by(&:genre).map do |gen|
        { value: gen.id, label: gen.genre, search_only: gen.search_only }
      end
      render json: genres
    end
  end