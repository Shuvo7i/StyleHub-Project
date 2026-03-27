ActiveAdmin.register Product do
  permit_params :category_id, :name, :description, :sku, :price, :stock_quantity,
                :size, :color, :material, :on_sale, :featured, :image

  index do
    selectable_column
    id_column
    column :name
    column :category
    column :sku
    column :price
    column :stock_quantity
    column :on_sale
    column :featured
    actions
  end

  filter :name
  filter :sku
  filter :category
  filter :on_sale
  filter :featured

  form do |f|
    f.inputs do
      f.input :category
      f.input :name
      f.input :description
      f.input :sku
      f.input :price
      f.input :stock_quantity
      f.input :size
      f.input :color
      f.input :material
      f.input :on_sale
      f.input :featured
      f.input :image, as: :file
    end
    f.actions
  end
show do
  attributes_table do
    row :color
    row :image do |product|
      if product.image.attached?
        image_tag url_for(product.image), width: 120
      else
        "No image uploaded"
      end
    end
  end
end
end
