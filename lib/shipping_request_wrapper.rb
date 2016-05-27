require 'httparty'

module ShippingRequestWrapper

  BASE_URL = "https://shipping-service-petsy.herokuapp.com/"
  # BASE_URL = "http://localhost:3000/"

  def self.all_estimates(order)
    data = HTTParty.post(BASE_URL + "shipping_requests",
    {
      :body => {"destination_zip" => order.billing_zip, 
        "number_of_items" => order.orderitems.length,
        "order_id" => order.id }.to_json,
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
      }).parsed_response
    return data
  end
  #
  # def self.ups(id)
  #   data = HTTParty.get(BASE_URL + "/ups/#{id}").parsed_response["estimates"]
  #   return data
  # end
  #
  # def self.fedex(id)
  #   data = HTTParty.get(BASE_URL + "/fedex/#{id}").parsed_response["estimates"]
  #   return data
  # end
end
