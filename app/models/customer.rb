class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

  VALID_PROVINCES = %w[AB BC MB NB NL NT NS NU ON PE QC SK YT].freeze
  CANADIAN_POSTAL_CODE_REGEX = /\A[ABCEGHJ-NPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][ -]?\d[ABCEGHJ-NPRSTV-Z]\d\z/i

  before_validation :normalize_fields

  validates :name, :email, :address, :city, :province, :postal_code, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }
  validates :province, inclusion: { in: VALID_PROVINCES }
  validates :postal_code, format: { with: CANADIAN_POSTAL_CODE_REGEX }

  private

  def normalize_fields
    self.name = name.to_s.strip
    self.email = email.to_s.strip.downcase
    self.address = address.to_s.strip
    self.city = city.to_s.strip
    self.province = province.to_s.strip.upcase
    self.postal_code = postal_code.to_s.strip.upcase
  end
end
