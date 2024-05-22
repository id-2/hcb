# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :signed_in_user, only: [:auth, :auth_submit, :choose_login_preference, :set_login_preference, :webauthn_options, :webauthn_auth, :login_code, :exchange_login_code]
  skip_before_action :redirect_to_onboarding, only: [:edit, :update, :logout, :unimpersonate]
  skip_after_action :verify_authorized, except: [:edit, :update]
  before_action :set_shown_private_feature_previews, only: [:edit, :edit_featurepreviews, :edit_security, :edit_admin]
  before_action :migrate_return_to, only: [:auth, :auth_submit, :choose_login_preference, :login_code, :exchange_login_code, :webauthn_auth]

  wrap_parameters format: :url_encoded_form

  def impersonate
    authorize current_user

    user = User.find(params[:id])

    impersonate_user(user)

    redirect_to params[:return_to] || root_path, flash: { info: "You're now impersonating #{user.name}." }
  end

  def unimpersonate
    return redirect_to root_path unless current_session&.impersonated?

    impersonated_user = current_user

    unimpersonate_user

    redirect_to params[:return_to] || root_path, flash: { info: "Welcome back, 007. You're no longer impersonating #{impersonated_user.name}" }
  end

  # view to log in
  def auth
    @prefill_email = params[:email] if params[:email].present?
    @return_to = params[:return_to]
  end

  def auth_submit
    @email = params[:email]
    user = User.find_by(email: @email)
    @session = create_session(user:)

    has_webauthn_enabled = user&.webauthn_credentials&.any?
    login_preference = session[:login_preference]

    if !has_webauthn_enabled || login_preference == "email"
      redirect_to login_code_user_session_path(@session), status: :temporary_redirect
    else
      session[:auth_email] = @email
      redirect_to choose_login_preference_user_session_path(@session, return_to: params[:return_to])
    end
  end

  def logout
    sign_out
    redirect_to root_path
  end

  def logout_all
    sign_out_of_all_sessions
    redirect_back_or_to security_user_path(current_user), flash: { success: "Success" }
  end

  def logout_session
    begin
      session = UserSession.find(params[:id])
      if session.user.id != current_user.id
        Rail.logger.error "User id: #{user.id} tried to delete session #{session.id}"
        flash[:error] = "Error deleting the session"
        return
      end

      session.destroy
      flash[:success] = "Deleted session!"
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = "Session is not found"
    end
    redirect_to root_path
  end

  def revoke_oauth_application
    Doorkeeper::Application.revoke_tokens_and_grants_for(params[:id], current_user)
    redirect_back_or_to security_user_path(current_user)
  end

  def receipt_report
    ReceiptReportJob::Send.perform_later(current_user.id, force_send: true)
    flash[:success] = "Receipt report generating. Check #{current_user.email}"
    redirect_to settings_previews_path
  end

  def edit
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @onboarding = @user.onboarding?
    @mailbox_address = @user.active_mailbox_address
    show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
    @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
    authorize @user
  end

  def edit_address
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @states = [
      ISO3166::Country.new("US").subdivisions.values.map { |s| [s.translations["en"], s.code] },
      ISO3166::Country.new("CA").subdivisions.values.map { |s| [s.translations["en"], s.code] }
    ].flatten(1)
    redirect_to edit_user_path(@user) unless @user.stripe_cardholder
    @onboarding = @user.full_name.blank?
    show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
    @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
    authorize @user
  end

  def edit_payout
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    authorize @user
  end

  def edit_featurepreviews
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @onboarding = @user.full_name.blank?
    show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
    @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
    authorize @user
  end

  def edit_security
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @onboarding = @user.full_name.blank?
    show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
    @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
    @oauth_authorizations = @user.api_tokens
                                 .where.not(application_id: nil)
                                 .select("application_id, MAX(api_tokens.created_at) AS created_at, MIN(api_tokens.created_at) AS first_authorized_at, COUNT(*) AS authorization_count")
                                 .accessible
                                 .group(:application_id)
                                 .includes(:application)
    @all_sessions = (@sessions + @oauth_authorizations).sort_by { |s| s.created_at }.reverse!

    authorize @user
  end

  def edit_admin
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @onboarding = @user.full_name.blank?
    show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
    @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated

    # User Information
    @invoices = Invoice.where(creator: @user)
    @check_deposits = CheckDeposit.where(created_by: @user)
    @increase_checks = IncreaseCheck.where(user: @user)
    @lob_checks = Check.where(creator: @user)
    @ach_transfers = AchTransfer.where(creator: @user)
    @disbursements = Disbursement.where(requested_by: @user)

    authorize @user
  end

  def update
    @states = ISO3166::Country.new("US").subdivisions.values.map { |s| [s.translations["en"], s.code] }
    @user = User.friendly.find(params[:id])
    authorize @user

    if @user.admin? && params[:user][:running_balance_enabled].present?
      enable_running_balance = params[:user][:running_balance_enabled] == "1"
      if @user.running_balance_enabled? != enable_running_balance
        @user.update_attribute(:running_balance_enabled, enable_running_balance)
      end
    end

    if params[:user][:locked].present?
      locked = params[:user][:locked] == "1"
      if locked && @user == current_user
        flash[:error] = "As much as you might desire to, you cannot lock yourself out."
        return redirect_to admin_user_path(@user)
      elsif locked && @user.admin?
        flash[:error] = "Contact a engineer to lock out another admin."
        return redirect_to admin_user_path(@user)
      elsif locked
        @user.lock!
      else
        @user.unlock!
      end
    end

    if @user.update(user_params)
      confetti! if !@user.seasonal_themes_enabled_before_last_save && @user.seasonal_themes_enabled? # confetti if the user enables seasonal themes

      if @user.full_name_before_last_save.blank?
        flash[:success] = "Profile created!"
        redirect_to root_path
      else
        if @user.payout_method&.saved_changes? && @user == current_user
          flash[:success] = "Your payout details have been updated. We'll use this information for all payouts going forward."
        else
          flash[:success] = @user == current_user ? "Updated your profile!" : "Updated #{@user.first_name}'s profile!"
        end

        ::StripeCardholderService::Update.new(current_user: @user).run

        redirect_back_or_to edit_user_path(@user)
      end
    else
      @onboarding = User.friendly.find(params[:id]).full_name.blank?
      show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
      @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
      if @user.stripe_cardholder&.errors&.any?
        flash.now[:error] = @user.stripe_cardholder.errors.first.full_message
        render :edit_address, status: :unprocessable_entity and return
      end
      if @user.payout_method&.errors&.any?
        flash.now[:error] = @user.payout_method.errors.first.full_message
        render :edit_payout, status: :unprocessable_entity and return
      end
      render :edit, status: :unprocessable_entity
    end
  end

  def delete_profile_picture
    @user = User.friendly.find(params[:user_id])
    authorize @user

    @user.profile_picture.purge_later

    flash[:success] = "Switched back to your Gravatar."
    redirect_to edit_user_path(@user.slug)
  end

  def start_sms_auth_verification
    authorize current_user
    svc = UserService::EnrollSmsAuth.new(current_user)
    svc.start_verification
    # flash[:info] = "Verifying phone number"
    # redirect_to edit_user_path(current_user)
    render json: { message: "started verification successfully" }, status: :ok
  end

  def complete_sms_auth_verification
    authorize current_user
    params.require(:code)
    svc = UserService::EnrollSmsAuth.new(current_user)
    svc.complete_verification(params[:code])
    svc.enroll_sms_auth if params[:enroll_sms_auth]
    # flash[:success] = "Completed verification"
    # redirect_to edit_user_path(current_user)
    render json: { message: "completed verification successfully" }, status: :ok
  rescue ::Errors::InvalidLoginCode
    # flash[:error] = "Invalid login code"
    # redirect_to edit_user_path(current_user)
    render json: { error: "invalid login code" }, status: :forbidden
  end

  def toggle_sms_auth
    authorize current_user
    svc = UserService::EnrollSmsAuth.new(current_user)
    if current_user.use_sms_auth
      svc.disable_sms_auth
    else
      svc.enroll_sms_auth
    end
    redirect_back_or_to security_user_path(current_user)
  end

  private

  def set_shown_private_feature_previews
    @shown_private_feature_previews = params[:classified_top_secret]&.split(",") || []
  end

  def user_params
    attributes = [
      :full_name,
      :preferred_name,
      :phone_number,
      :profile_picture,
      :pretend_is_not_admin,
      :sessions_reported,
      :session_duration_seconds,
      :receipt_report_option,
      :birthday,
      :seasonal_themes_enabled,
      :payout_method_type,
      :comment_notifications
    ]

    if @user.stripe_cardholder
      attributes << {
        stripe_cardholder_attributes: [
          :stripe_billing_address_line1,
          :stripe_billing_address_line2,
          :stripe_billing_address_city,
          :stripe_billing_address_state,
          :stripe_billing_address_postal_code,
          :stripe_billing_address_country
        ]
      }
    end

    if params.require(:user)[:payout_method_type] == User::PayoutMethod::Check.name
      attributes << {
        payout_method_attributes: [
          :address_line1,
          :address_line2,
          :address_city,
          :address_state,
          :address_postal_code,
          :address_country
        ]
      }
    end

    if params.require(:user)[:payout_method_type] == User::PayoutMethod::AchTransfer.name
      attributes << {
        payout_method_attributes: [
          :account_number,
          :routing_number
        ]
      }
    end

    if superadmin_signed_in?
      attributes << :access_level
    end

    params.require(:user).permit(attributes)
  end

  def initialize_sms_params
    return if @force_use_email

    user = User.find_by(email: @email)
    if user&.use_sms_auth
      @use_sms_auth = true
      @phone_last_four = user.phone_number.last(4)
    end
  end

  # HCB used to run on bank.hackclub.com— this ensures that any old references to `bank.` URLs are translated into `hcb.`
  def migrate_return_to
    if params[:return_to].present?
      uri = URI(params[:return_to])

      if uri&.host == "bank.hackclub.com"
        uri.host = "hcb.hackclub.com"
        params[:return_to] = uri.to_s
      end
    end

  rescue URI::InvalidURIError
    params.delete(:return_to)
  end

end
