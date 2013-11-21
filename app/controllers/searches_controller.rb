class SearchesController < ApplicationController
  def edit
  end

  def show
    params.require(:query)
    @songs = LyricsApi.search(params[:query])
  end
end
