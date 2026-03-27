ActiveAdmin.register Category do
    config.batch_actions = false
  permit_params :name, :description

  index do
    selectable_column
    id_column
    column :name
    column :description
    actions defaults: false do |category|
  item "View", admin_category_path(category)
  item "Edit", edit_admin_category_path(category)

  span do
    button_to "Delete",
              admin_category_path(category),
              method: :delete,
              form: { style: "display:inline",
            onsubmit: "return confirm('Are you sure you want to delete this category?');"}
  end
end
  end

  filter :name

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
    end
    f.actions
  end

end