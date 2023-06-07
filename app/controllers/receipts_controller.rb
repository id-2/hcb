# frozen_string_literal: true

require "uri"
require "timeout"

class ReceiptsController < ApplicationController
  skip_after_action :verify_authorized, only: :upload # do not force pundit
  skip_before_action :signed_in_user, only: :upload
  before_action :set_paper_trail_whodunnit, only: :upload
  before_action :find_receiptable, only: [:upload, :link, :link_modal]

  def destroy
    @receipt = Receipt.find(params[:id])
    @receiptable = @receipt.receiptable
    authorize @receipt

    if @receipt.delete
      flash[:success] = "Deleted receipt"
      redirect_to @receiptable || my_inbox_path
    else
      flash[:error] = "Failed to delete receipt"
      redirect_to @receiptable
    end
  end

  def link
    params.require(:receipt_id)
    params.require(:receiptable_type)
    params.require(:receiptable_id)

    @receipt = Receipt.find(params[:receipt_id])

    authorize @receipt
    authorize @receiptable, policy_class: ReceiptablePolicy

    @receipt.update!(receiptable: @receiptable)

    if params[:show_link]
      flash[:success] = { text: "Receipt linked!", link: (hcb_code_path(@receiptable) if @receiptable.instance_of?(HcbCode)), link_text: "View" }
    else
      flash[:success] = "Receipt added!"
    end

    if params[:redirect_url]
      redirect_to params[:redirect_url]
    else
      redirect_back fallback_location: @receiptable.try(:hcb_code) || @receiptable
    end
  end

  def link_modal
    @receipts = Receipt.where(user: current_user, receiptable: nil).to_a
    @pairings = {}

    @receipts.each_with_index do |receipt, index|
      suggested_pairing = index > 3

      @pairings[receipt.id] = suggested_pairing
      if suggested_pairing
        @receipts = @receipts.insert(0, @receipts.delete_at(index))
      end
    end

    # if @pairings[receipt.id] === true, then bring the receipt to the top of the list



    authorize @receiptable, policy_class: ReceiptablePolicy

    render :link_modal, layout: false
  end


  def upload
    params.require(:file)
    params.require(:upload_method)

    begin
      if @receiptable
        authorize @receiptable, policy_class: ReceiptablePolicy
      end
    rescue Pundit::NotAuthorizedError
      @has_valid_secret = @receiptable.instance_of?(HcbCode) && HcbCodeService::Receipt::SigningEndpoint.new.valid_url?(@receiptable.hashid, params[:s])

      raise unless @has_valid_secret
    end

    pairing_receipt = nil
    pairing_hcb_code = nil

    if params[:file] # Ignore if no files were uploaded
      receipts = params[:file].map do |file|
        ::ReceiptService::Create.new(
          receiptable: @receiptable,
          uploader: current_user,
          attachments: [file],
          upload_method: params[:upload_method]
        ).run!.to_a.first
      end

      if receipts.length == 1
        begin
          Timeout::timeout(3) do
            hcb_code = ::ReceiptService::Suggest.new(receipt: receipts.first).run!
    
            if !hcb_code.nil?
              pairing_receipt = receipts.first.id
              pairing_hcb_code = hcb_code[:txn].hashid
            end
          end
        rescue Timeout::Error
          
        end
      end

      if params[:show_link]
        flash[:success] = { text: "#{"Receipt".pluralize(params[:file].length)} added!", link: (hcb_code_path(@receiptable) if @receiptable.instance_of?(HcbCode)), link_text: "View" }
      else
        flash[:success] = "#{"Receipt".pluralize(params[:file].length)} added!"
      end
    end
  rescue => e
    notify_airbrake(e)

    puts e.inspect

    flash[:error] = e.message
  ensure
    if params[:redirect_url]
      uri = URI.parse(params[:redirect_url])
      params = {
        pairing_receipt: pairing_receipt,
        pairing_hcb_code: pairing_hcb_code
      }

      uri.query = URI.encode_www_form(params)

      redirect_to uri.to_s
    else
      redirect_back fallback_location: @receiptable&.try(:url) || @receiptable || my_inbox_path, params: { pairing_receipt: pairing_receipt, pairing_hcb_code: pairing_hcb_code }
    end
  end

  private

  def find_receiptable
    if params[:receiptable_type].present? && params[:receiptable_id].present?
      @klass = params[:receiptable_type].constantize
      @receiptable = @klass.find(params[:receiptable_id])
    end
  end

end
