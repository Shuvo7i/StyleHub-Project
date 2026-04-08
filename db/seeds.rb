# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?



#FAKER
# require "faker"

# Product.destroy_all
# Category.destroy_all


# categories = [
#   { name: "Hoodies", description: "Warm hoodies" },
#   { name: "Shoes", description: "Stylish shoes" },
#   { name: "T-Shirts", description: "Casual shirts" },
#   { name: "Accessories", description: "Fashion accessories" }
# ]

# created_categories = categories.map do |cat|
#   Category.create!(cat)
# end

# 100.times do
#   category = created_categories.sample

#   Product.create!(
#     category: category,
#     name: Faker::Commerce.product_name,
#     description: Faker::Lorem.sentence(word_count: 10),
#     sku: Faker::Code.unique.asin,
#     price: Faker::Commerce.price(range: 20.0..100.0),
#     stock_quantity: rand(5..50),
#     size: %w[S M L XL].sample,
#     color: Faker::Color.color_name,
#     material: %w[Cotton Denim Leather Polyester].sample,
#     on_sale: [true, false].sample,
#     featured: [true, false].sample
#   )
# end
# puts "Done!"
# puts "Created #{Category.count} categories"
# puts "Created #{Product.count} products"


#api 

# require_relative "../app/services/dummy_json_seed"

# puts "Importing categories and products from DummyJSON..."
# DummyJsonSeed.run
# puts "Done!"
# puts "Categories: #{Category.count}"
# puts "Products: #{Product.count}"

Province.destroy_all

[
  ["Alberta", "AB"],
  ["British Columbia", "BC"],
  ["Manitoba", "MB"],
  ["New Brunswick", "NB"],
  ["Newfoundland and Labrador", "NL"],
  ["Northwest Territories", "NT"],
  ["Nova Scotia", "NS"],
  ["Nunavut", "NU"],
  ["Ontario", "ON"],
  ["Prince Edward Island", "PE"],
  ["Quebec", "QC"],
  ["Saskatchewan", "SK"],
  ["Yukon", "YT"]
].each do |name, code|
  Province.create!(name: name, code: code)
end