require 'json'

module ApplicationHelper
  def json_shipping_value
    number_with_precision (JSON.parse(@order.shipping_method).values.first.first / 100.0) , precision: 2
  end
end
