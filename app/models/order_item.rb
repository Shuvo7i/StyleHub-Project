class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :order, :product, presence: true
  validates :product_id, uniqueness: { scope: :order_id }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :subtotal_matches_line_total

  private

  def subtotal_matches_line_total
    return if quantity.blank? || unit_price.blank? || subtotal.blank?

    expected_subtotal = quantity.to_i * unit_price.to_d
    return if subtotal.to_d == expected_subtotal.round(2)

    errors.add(:subtotal, "must equal quantity multiplied by unit price")
  end
end
