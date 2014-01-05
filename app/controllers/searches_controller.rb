class SearchesController < ApplicationController
  def edit
  end

  def show
    params.require(:query)
    @query = params[:query]
    @songs = LyricsApi.search(@query)
  end
end
