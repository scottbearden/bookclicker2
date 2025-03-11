class PenName < ApplicationRecord
  
  belongs_to :owner, class_name: User, foreign_key: :user_id
  has_many :users_pen_names
  has_many :users, through: :users_pen_names
  has_many :other_users, -> { where () }
  
  has_many :pen_name_requests
  
  has_many :lists
  has_many :books
  
  
  before_validation :set_promo_service_requirements, if: :promo_service_only?
  
  validates_presence_of :author_name
  validate :promo_service_doesnt_have_books
  validate :no_illegal_changes_for_shared_pen_name
  validate :not_already_taken
  validate :can_delete?, if: proc { deleted? && deleted_changed? }
  
  scope :not_promo_service, -> { where(promo_service_only: 0) }
  scope :active, -> { where(deleted: false) }

  default_scope { active }
  
  enum group_status: { "open" => "open", "closed" => "closed" }
  
  after_commit :generate_adopted_pen_names, if: Proc.new { |pen_name| pen_name.previous_changes.include?("author_name") }
  after_commit :ensure_proper_ownership

  def can_delete?
    if users_pen_names.count > 1
      errors.add(:base, "More than one user is sharing this pen name.  See who is sharing it <a href='/pen_names/sharing'>here</a>")
      return false
    elsif lists.active.present?
      errors.add(:base, "You must disassociate all active lists from this pen name <a href='/my_lists/selections'>here</a>")
      return false
    elsif books.present?
      errors.add(:base, "All books using this pen name must first be deleted")
      return false
    else
      return true
    end
  end

  def author_name
    deleted? ? "< info deleted >" : self[:author_name]
  end
  
  def self.users_pen_names_includes_books_json(user)
    pen_names_with_books = user.pen_names_used.includes({:books => :book_links}).order("users_pen_names.created_at")
    result = []
    pen_names_with_books.each do |pen_name|
      result.push(
        pen_name.as_json(methods: [:can_delete?]).merge(books: pen_name.books.reject { |book| book.user_id != user.id })
      )
    end
    result.as_json(Book::JSON_WITH_LINKS)
  end
  
  def promo_service_doesnt_have_books
    if promo_service_only? && books.present?
      errors.add(:base, "Promo services may not have books")
    end
  end
  
  def self.generate_adopted_pen_names_for_lists(pen_name_ids)
    PenName.where(id: pen_name_ids).each do |pen_name|
      lists = pen_name.lists.order(:id) # 'the lists are numbered in order of creation'
      if lists.length == 1
        lists.first.update_column(:adopted_pen_name, pen_name.author_name)
      elsif lists.length > 1
        lists.each_with_index do |list, idx|
          list.update_column(:adopted_pen_name, "#{pen_name.author_name} ##{idx + 1}")
        end
      end
    end
  end
  
  def generate_adopted_pen_names
    pen_name_ids = [self.id]
    PenName.generate_adopted_pen_names_for_lists(pen_name_ids)
  end
  
  def no_illegal_changes_for_shared_pen_name
    if self.users.length > 1
      if author_name_changed? && author_name.to_s.lev_distance_to(author_name_was.to_s) > 2
        errors.add(:base, "You can't change the name of a shared pen name")
      elsif verified_changed? && !verified?
        errors.add(:base, "You can't unverify a shared pen name")
      elsif group_status_changed? && group_status.blank?
        errors.add(:base, "You can't remove group access from a shared pen name")
      elsif promo_service_only_changed? && promo_service_only?
        errors.add(:base, "You cannot change this to a promo service")
      end
    end
  end
  
  def ensure_proper_ownership
    if self.users.length == 1 && self.user_id != self.users.first.id
      self.update_column(:user_id, self.users.first.id)
    end
  end
  
  def not_already_taken
    if author_name_changed? && identical_pen_name.present?
      errors.add(:base, "This name has already been claimed")
    end
  end
  
  def identical_pen_name
    return nil unless author_name.present?
    @identical_pen_name ||= PenName.where(author_name: self.author_name.strip, promo_service_only: 0).where.not(id: self.id).first
  end
  
  def set_promo_service_requirements
    self.verified = 0
    self.group_status = nil
  end
  
  def users_ids
    users_pen_names.pluck(:user_id)
  end
  
end
