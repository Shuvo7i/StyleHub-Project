class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  VALID_STATUSES = %w[pending paid failed cancelled canceled].freeze
  VALID_PAYMENT_STATUSES = %w[pending paid failed cancelled canceled].freeze

  validates :customer, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validates :payment_status, presence: true, inclusion: { in: VALID_PAYMENT_STATUSES }
  validates :subtotal, :gst_amount, :pst_amount, :hst_amount, :total,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :stripe_checkout_session_id, uniqueness: true, allow_blank: true
  validate :total_matches_tax_breakdown

  def provincial_tax_label
    case customer.province
    when "QC"
      "QST"
    when "MB"
      "RST"
    when "BC", "SK"
      "PST"
    else
      nil
    end
  end

  private

  def total_matches_tax_breakdown
    return if subtotal.blank? || gst_amount.blank? || pst_amount.blank? || hst_amount.blank? || total.blank?

    expected_total = subtotal.to_d + gst_amount.to_d + pst_amount.to_d + hst_amount.to_d
    return if total.to_d == expected_total.round(2)

    errors.add(:total, "must equal subtotal plus taxes")
  end
end
