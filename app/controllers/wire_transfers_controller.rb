class WireTransfersController < ApplicationController
  before_action :set_wire_transfer, except: [:new, :create, :index, :validate_bic_code]
  before_action :set_event, only: [:new, :create]

  # GET /ach_transfers/1
  def show
    authorize @wire_transfer

    redirect_to @wire_transfer.local_hcb_code
  end

  # def transfer_confirmation_letter
  #   authorize @wire_transfer

  #   respond_to do |format|
  #     # unless @wire_transfer.deposited?
  #     #   redirect_to @ach_transfer and return
  #     # end

  #     format.html do
  #       redirect_to @wire_transfer
  #     end

  #     format.pdf do
  #       render pdf: "Wire Transfer ##{@wire_transfer.id} Confirmation Letter (#{@event.name} to #{@wire_transfer.recipient_name} on #{@wire_transfer.canonical_pending_transaction.date.strftime("%B #{@wire_transfer.canonical_pending_transaction.date.day.ordinalize}, %Y")})", page_height: "11in", page_width: "8.5in"
  #     end
  #   end
  # end

  # GET /ach_transfers/new
  def new
    @ach_transfer = AchTransfer.new(event: @event)
    authorize @ach_transfer
  end

  # POST /ach_transfers
  def create
    @ach_transfer = @event.ach_transfers.build(ach_transfer_params.except(:file).merge(creator: current_user))

    authorize @ach_transfer

    if @ach_transfer.save
      if ach_transfer_params[:file]
        ::ReceiptService::Create.new(
          uploader: current_user,
          attachments: ach_transfer_params[:file],
          upload_method: :transfer_create_page,
          receiptable: @ach_transfer.local_hcb_code
        ).run!
      end
      redirect_to event_transfers_path(@event), flash: { success: "ACH transfer successfully submitted." }
    else
      render :new, status: :unprocessable_entity
    end
  end

  def validate_bic_code
    skip_authorization

    return render json: { valid: true } if params[:value].empty?
    return render json: { valid: false, hint: "Bank not found for this SWIFT/BIC code." } unless /\A[A-Z0-9]+\z/.match?(params[:value])
    puts "tryintovalidate", params[:value]

    bank = ColumnService.get "/institutions/#{params[:value]}" # This is safe since params[:value] is validated to only contain digits above

    puts "BVNAKOSNDEBA", bank
    if bank["routing_number_type"] != "bic"
      render json: {
        valid: false,
        hint: "Please enter an SWIFT/BIC code."
      }
    else
      render json: {
        valid: true,
        hint: bank["full_name"].titleize
      }
    end
  rescue Faraday::BadRequestError
    return render json: { valid: false, hint: "Bank not found for this SWIFT/BIC code." }
  rescue => e
    notify_airbrake(e)
    render json: { valid: true }
  end

  private

  def set_wire_transfer
    @wire_transfer = WireTransfer.find(params[:id] || params[:wire_transfer_id])
    @event = @wire_transfer.event
  end

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

end
