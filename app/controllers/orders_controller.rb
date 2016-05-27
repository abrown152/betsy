require 'shipping_request_wrapper'

class OrdersController < ApplicationController
  before_action :require_login, only: [:show_seller_orders]

  def show
    @orders = Order.find(current_order.id).orderitems
  end

  def show_seller_orders
  	@user = User.find(current_user.id)
    @user_orders_hash = Orderitem.where(user: current_user).group_by(&:order_id)
    @revenue = @user.revenue
    @completed_revenue = @user.revenue_by_status("Completed")
    @pending_revenue = @user.revenue_by_status("Pending")
    @completed_count = @user.order_by_status("Completed")
    @pending_count = @user.order_by_status("Pending")
  end

  def order_deets
    @user_orders_hash = Orderitem.where(user: current_user).group_by(&:order_id)
    @order = Order.find(params[:order_id])
  end


  def edit
    @order  = Order.find(params[:id])
    @orderitems = Order.find(current_order.id).orderitems
  end

  def update
    @order = current_order
    @orderitems = @order.orderitems
    continue = remove_items_from_stock(@orderitems)
    if continue
      if @order.update(order_update_params[:order])
        redirect_to order_shipping_path(@order)
      else
        flash[:notice] = "Sorry! We couldn't process this request."
        redirect_to edit_order_path(current_order.id)
      end
    else
      flash[:notice] = "Sorry! An item you wanted is out of stock. Check to see if you have duplicate items in your cart."
      redirect_to edit_order_path(current_order.id)
    end
  end

  def checkout
    @order = current_order
    if @order.orderitems.count == 0
      redirect_to edit_order_path(current_order.id), alert: "Please add items to your cart!"
    end
  end

  def confirmation
    @order = current_order
    @orderitems = @order.orderitems
    session.delete :order_id
    # order = Order.create
    # order.update(status: "Pending")
    # session[:order_id] = order.id
  end

  def update_before_shipping
    @order = current_order
    @order.update(order_update_params[:order])
    redirect_to order_shipping_path(@order.id)
  end

  def shipping
    @order = current_order
    @shipping_options = assemble_pricing_options(@order)["estimates"]#needs @order when we remove set pricing in assmeble pricing method.
  end

  def update_shipping
    @order = current_order
    @order.update(shipping_method: params[:order][:shipping_method])
    redirect_to order_confirmation_path(@order.id)
  end

  private

  def remove_items_from_stock(items)
    items.each do |item|
      product = item.product
      quantity_being_bought = item.quantity
      available_quantity = product.quantity
      new_quantity = available_quantity - quantity_being_bought
      if new_quantity >= 0
        product.update(quantity: new_quantity)
      else
        return false
      end
    end
  end

  def orderitem_edit_params
    params.permit(orderitem: [:quantity])
  end

  def order_update_params
    params[:order][:credit_card_number] = params[:order][:credit_card_number][-4..-1]
    params.permit(order: [:name_on_credit_card, :user_id, :city, :state, :billing_zip,
      :email, :status, :street_address, :credit_card_cvv, :credit_card_number, :credit_card_exp_date])
  end

  def assemble_pricing_options(order)
    #assembles the total pricing from shipping services for a given order
    ShippingRequestWrapper.all_estimates(order) 
  end

end
