class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
  class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      matching_movies = Tmdb::Movie.find(string)
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
    
    if matching_movies.nil? or matching_movies.empty?
      return []
    end
    
    return matching_movies.map { |movie|
      {
        :tmdb_id => movie.id,
        :title => movie.title,
        :rating => Tmdb::Movie.releases(movie.id)["countries"].find {|r| not r["certification"].empty?}["certification"],
        :release_date => movie.release_date
      }
    }
  end

  def self.create_from_tmdb(id)
    m = Tmdb::Movie.detail(id)
    rating = Tmdb::Movie.releases(id)["countries"].find {|r| not r["certification"].empty?}["certification"]
    return Movie.create!({
      :title => m["title"],
      :release_date => m["release_date"],
      :rating => rating,
      :description => m["overview"]
    })
  end
end
