class AddProvinceToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :province, foreign_key: true
  end
end