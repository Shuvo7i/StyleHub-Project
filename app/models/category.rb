class Category < ApplicationRecord
  has_many :products, dependent: :destroy

  before_validation :normalize_fields

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["description", "name"]
  end

  private

  def normalize_fields
    self.name = name.to_s.strip
    self.description = description.to_s.strip
  end
end
