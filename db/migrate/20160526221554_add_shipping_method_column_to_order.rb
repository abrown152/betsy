class AddShippingMethodColumnToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_method, :string
  end
end
