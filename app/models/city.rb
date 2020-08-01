class City < ApplicationRecord
  self.primary_key = 'name'

  validates :name, presence: true, uniqueness: true
  validate :name_has_no_spaces

  def name_has_no_spaces
    errors.add(:name, "has spaces") if name.include?(' ')
  end
end
