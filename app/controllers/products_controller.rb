class ProductsController < ApplicationController
  def create
    
    params = product_params
    
    params[:amount] = (product_params[:amount].to_f * 100).to_i
    
    @product = Product.new(params)
    
    authorize @product
  
    @product.save
    
    redirect_to event_products_path(event_id: @product.event.slug), flash: { success: "Your product is ready to sell!" }
  end
  
  def update
    
    params = product_params
    
    params[:amount] = (product_params[:amount].to_f * 100).to_i
    
    @product = Product.find(params[:id])
    
    authorize @product
    
    @product.amount = params[:amount]
    
    @product.name = params[:name]
    
    @product.save
    
    redirect_to event_products_path(event_id: @product.event.slug), flash: { success: "Updated #{params[:name]}" }
  end
  
  def delete
    
    @product = Product.find(product_params[:format])
    
    authorize @product
    
    @product.delete
    
    redirect_to event_products_path(event_id: @product.event.slug), flash: { success: "Deleted #{@product.name}" }
    
  end
  
  def buy
    @product = Product.find(params[:id])
    @event = @product.event
    skip_authorization
  end
  
  private
  
  def product_params
    params.permit(:name, :amount, :event_id, :id, :format)
  end
end
