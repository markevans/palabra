class SongsController < ApplicationController
  def show
    params.require(:url)
    @song = LyricsApi.song(params[:url])
  end
end
