class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

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
end