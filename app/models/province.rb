class Province < ApplicationRecord
  has_many :users

  validates :name, :code, presence: true
  validates :code, uniqueness: true
end