class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    entered_ratings = params[:ratings]
    @sort_param = params[:sort_param]
    
    if entered_ratings.nil? && (@sort_param.nil? || @sort_param.empty?)
      if session.key?(:ratings) && session.key?(:sort_param)
        @sort_param = session[:sort_param]
        @ratings_to_show = session[:ratings].keys
        redirect_to movies_path({:ratings => session[:ratings], :sort_param => @sort_param}) and return
      elsif session.key?(:ratings)
        @ratings_to_show = session[:ratings].keys
        redirect_to movies_path({:ratings => session[:ratings]}) and return
      elsif session.key?(:sort_param)
        @sort_param = session[:sort_param]
        redirect_to movies_path({:sort_param => @sort_param}) and return
      elsif !(session.key?(:ratings))
        @ratings_to_show = @all_ratings
      end
      
    elsif entered_ratings.nil?
      @ratings_to_show = []
      session.delete(:ratings)
    else
      @ratings_to_show = entered_ratings.keys 
      session[:ratings] = entered_ratings
    end
    @ratings_to_show_hash = Hash[@ratings_to_show.collect {|r| [r, 1]}]

    if @sort_param.nil? || @sort_param.empty?
      @movies = Movie.with_ratings(@ratings_to_show)
      @highlight_title = nil
      @highlight_release_date = nil
    else
      @movies = Movie.with_ratings(@ratings_to_show).order("#{@sort_param} ASC")
      session[:sort_param] = @sort_param
      if @sort_param == "title"
        @highlight_title = "bg-warning"
      else
        @highlight_release_date = "bg-warning"
      end
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
