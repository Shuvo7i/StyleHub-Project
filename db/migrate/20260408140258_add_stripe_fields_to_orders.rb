class AddStripeFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :stripe_checkout_session_id, :string
    add_column :orders, :stripe_payment_intent_id, :string
    add_column :orders, :payment_status, :string, default: "pending", null: false

    add_index :orders, :stripe_checkout_session_id, unique: true
    add_index :orders, :stripe_payment_intent_id
  end
end