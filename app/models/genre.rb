class Genre < ApplicationRecord
  
  validates_presence_of :genre
  has_many :lists
  
  def self.determine_main_category(genres)
    res = genres.group_by(&:category).max_by { |cat, entries| entries.length }
    res.try(:[], 0)
  end
  
  def self.convert_ids_to_marketplace_query(ids)
    genres = Genre.where(id: ids)
    generic_genres = genres.select(&:search_only?)
    specific_genres = genres.reject(&:search_only?)
    
    if generic_genres.present?
      category_clause = "genres.category in (#{generic_genres.map { |g| "\"#{g.category}\"" }.join(",")})"
    else
      category_clause = nil
    end
    if specific_genres.present?
      genre_id_clause = "genres.id in (#{specific_genres.map(&:id).join(",")})"
    else
      genre_id_clause = nil
    end
    [category_clause, genre_id_clause].compact.join(" OR ")
  end
  
end