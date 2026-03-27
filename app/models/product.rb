class Product < ApplicationRecord
  belongs_to :category

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

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
end