class User < ApplicationRecord
  belongs_to :province

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :province_id, presence: true
end