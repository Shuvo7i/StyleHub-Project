class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, :email, :province, presence: true
end