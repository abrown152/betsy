class CreateShippingRequests < ActiveRecord::Migration
  def change
    create_table :shipping_requests do |t|

      t.timestamps null: false
    end
  end
end
