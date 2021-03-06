require 'sinatra/base'
require 'rack-flash'
require 'pry'
class SongsController < ApplicationController
  enable :sessions
  use Rack::Flash

  get "/songs" do
    @songs = Song.all
    erb :'/songs/index'
  end

  post "/songs" do
    @song = Song.create(:name => params[:song_name])
    params[:genres].each do |id|
      @song.genres << Genre.find_by_id(id)
    end
    artist = Artist.find_or_create_by(:name => params[:artist])

    artist.songs << @song
    artist.save
    @song.save

    flash[:message] = "Successfully created song."
    redirect to :"/songs/#{@song.slug}"
  end


  get "/songs/:slug" do
    @song = Song.find_by_slug(params[:slug])
    erb :'/songs/show'
  end

  get "/songs/new" do
    erb :'songs/new'
  end


  get "/songs/:slug/edit" do
    @song = Song.find_by_slug(params[:slug])
    erb :'songs/edit'
  end

  patch '/songs/:slug' do
    @song = Song.find_by_slug(params[:slug])
    @song.update(:name => params[:name])
    artist = Artist.find_or_create_by(:name => params[:artist])
    artist.songs << @song
    artist.save
    params[:genres].each do |id|
      genre = Genre.find_by_id(id)
      if !@song.genres.include?(genre)
        @song.genres << genre
      end
    end
    @song.save

    flash[:message] = "Successfully updated song."
    redirect to :"/songs/#{@song.slug}"
  end

end