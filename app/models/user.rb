class User < ApplicationRecord
  belongs_to :province

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  CANADIAN_POSTAL_CODE_REGEX = /\A[ABCEGHJ-NPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][ -]?\d[ABCEGHJ-NPRSTV-Z]\d\z/i

  before_validation :normalize_fields
  before_validation :assign_province_from_legacy_value

  validates :username, :address, :city, :province_id, :postal_code, presence: true
  validates :username, length: { minimum: 2, maximum: 50 }
  validates :postal_code, format: { with: CANADIAN_POSTAL_CODE_REGEX }

  private

  def normalize_fields
    self.username = username.to_s.strip
    self.address = address.to_s.strip
    self.city = city.to_s.strip
    self.postal_code = postal_code.to_s.strip.upcase
  end

  def assign_province_from_legacy_value
    return if province_id.present?
    return if self[:province].blank?

    legacy_value = self[:province].to_s.strip
    matched_province = Province.find_by(code: legacy_value.upcase) || Province.find_by(name: legacy_value)
    self.province = matched_province if matched_province.present?
  end
end
