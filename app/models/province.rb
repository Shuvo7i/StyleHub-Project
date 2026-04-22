class Province < ApplicationRecord
  has_many :users

  before_validation :normalize_fields

  validates :name, :code, presence: true
  validates :code, uniqueness: { case_sensitive: false }, format: { with: /\A[A-Z]{2}\z/ }

  private

  def normalize_fields
    self.name = name.to_s.strip
    self.code = code.to_s.strip.upcase
  end
end
