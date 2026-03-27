require "httparty"

class DummyJsonSeed
  include HTTParty
  base_uri "https://dummyjson.com"

  def self.run
    Product.destroy_all
    Category.destroy_all

    categories_response = get("/products/categories")
    products_response = get("/products?limit=0")

    category_map = {}

    categories_response.parsed_response.each do |category_data|
      slug = category_data["slug"]
      name = category_data["name"]

      category_map[slug] = Category.create!(
        name: name,
        description: "Imported from DummyJSON API"
      )
    end

    products_response.parsed_response["products"].each do |product_data|
      category = category_map[product_data["category"]]

      Product.create!(
        category: category,
        name: product_data["title"],
        description: product_data["description"],
        sku: product_data["sku"].presence || "API-#{product_data["id"]}",
        price: product_data["price"],
        stock_quantity: product_data["stock"],
        size: "One Size",
        color: "Standard",
        material: product_data["brand"].presence || "Mixed",
        on_sale: product_data["discountPercentage"].to_f > 0,
        featured: product_data["rating"].to_f >= 4.5
      )
    end
  end
end