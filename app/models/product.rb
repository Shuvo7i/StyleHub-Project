class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image

  before_validation :normalize_fields
  before_validation :apply_defaults

  validates :category, :name, :description, :sku, :size, :color, :material, presence: true
  validates :sku, uniqueness: { case_sensitive: false }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :on_sale, :featured, inclusion: { in: [true, false] }
  validate :acceptable_image

  def self.ransackable_attributes(auth_object = nil)
    ["name",
    "category_id",
"sku",
"on_sale",
"featured"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["category"]
  end

  def displayable_image?
    return false unless image.attached? && image.blob.present?

    image.blob.service.exist?(image.blob.key)
  rescue StandardError
    false
  end

  private

  def normalize_fields
    self.name = name.to_s.strip
    self.description = description.to_s.strip
    self.sku = sku.to_s.strip
    self.size = size.to_s.strip
    self.color = color.to_s.strip
    self.material = material.to_s.strip
  end

  def apply_defaults
    self.size = "Standard" if size.blank?
    self.material = "Mixed" if material.blank?
  end

  def acceptable_image
    return unless image.attached?

    unless image.content_type.in?(%w[image/jpeg image/png image/webp image/gif])
      errors.add(:image, "must be a JPG, PNG, WEBP, or GIF")
    end

    return unless image.blob.byte_size > 5.megabytes

    errors.add(:image, "must be smaller than 5 MB")
  end
end
