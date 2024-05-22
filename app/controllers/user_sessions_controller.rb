class UserSessionsController < ApplicationController
  skip_before_action :signed_in_user
  skip_after_action :verify_authorized

  def choose_login_preference
    @session = UserSession.find(params[:id])
    @email = session[:auth_email]
    @user = User.find_by_email(@email)
    @return_to = params[:return_to]
    return redirect_to auth_users_path if @email.nil?
  
    session.delete :login_preference
  end
  
  def set_login_preference
    @session = UserSession.find(params[:id])
    @email = params[:email]
    remember = params[:remember] == "1"
  
    case params[:login_preference]
    when "email"
      session[:login_preference] = "email" if remember
      redirect_to login_code_user_session_path(@session), status: :temporary_redirect
    when "webauthn"
      # This should never happen, because WebAuthn auth is handled on the frontend
      redirect_to choose_login_preference_user_session_path(@session)
    end
  end
  
  # post to request login code
  def login_code
    @session = UserSession.find(params[:id])
    @return_to = params[:return_to]
    @email = params.require(:email)
    @force_use_email = params[:force_use_email]
  
    initialize_sms_params
  
    resp = LoginCodeService::Request.new(email: @email, sms: @use_sms_auth, ip_address: request.ip, user_agent: request.user_agent).run
  
    @use_sms_auth = resp[:method] == :sms
  
    if resp[:error].present?
      flash[:error] = resp[:error]
      return redirect_to auth_users_path
    end

    if resp[:login_code].present?
      cookies.signed[:"browser_token_#{resp[:login_code].id}"] = { value: resp[:browser_token], expires: LoginCode::EXPIRATION.from_now }
    end
  
    @user_id = resp[:id]
  
    @webauthn_available = User.find_by(email: @email)&.webauthn_credentials&.any?
  
    render status: :unprocessable_entity
  
  rescue ActionController::ParameterMissing
    flash[:error] = "Please enter an email address."
    redirect_to auth_users_path
  end
  
  def webauthn
    user = User.find_by(email: params[:email])
    @session = params[:id] == "new" ? create_session(user:) : UserSession.find(params[:id])
  
    if !user
      return redirect_to auth_users_path
    end
  
    webauthn_credential = WebAuthn::Credential.from_get(JSON.parse(params[:credential]))
  
    stored_credential = user.webauthn_credentials.find_by!(webauthn_id: webauthn_credential.id)
  
    begin
      webauthn_credential.verify(
        session[:webauthn_challenge],
        public_key: stored_credential.public_key,
        sign_count: stored_credential.sign_count
      )
  
      stored_credential.update!(sign_count: webauthn_credential.sign_count)
  
      fingerprint_info = {
        fingerprint: params[:fingerprint],
        device_info: params[:device_info],
        os_info: params[:os_info],
        timezone: params[:timezone],
        ip: request.remote_ip
      }
  
      session[:login_preference] = "webauthn" if params[:remember] == "true"
  
      complete_authentication_factor(session: @session, factor: :webauthn, fingerprint_info:, webauthn_credential: stored_credential)
      
      if @session.authenticated?
        redirect_to(params[:return_to] || root_path)
      else
        redirect_to login_code_user_session_path(@session), status: :temporary_redirect
      end
  
    rescue WebAuthn::SignCountVerificationError, WebAuthn::Error => e
      redirect_to auth_users_path, flash: { error: "Something went wrong." }
    rescue ActiveRecord::RecordInvalid => e
      redirect_to auth_users_path, flash: { error: e.record.errors&.full_messages&.join(". ") }
    end
  end
  
  # post to exchange auth token for access token
  def exchange_login_code
    @session = UserSession.find(params[:id])

    fingerprint_info = {
      fingerprint: params[:fingerprint],
      device_info: params[:device_info],
      os_info: params[:os_info],
      timezone: params[:timezone],
      ip: request.remote_ip
    }
  
    user = UserService::ExchangeLoginCodeForUser.new(
      user_id: params[:user_id],
      login_code: params[:login_code],
      sms: params[:sms],
      cookies:
    ).run
  
    complete_authentication_factor(session: @session, factor: params[:sms] ? :sms : :email, fingerprint_info:)
  
    # Clear the flash - this prevents the error message showing up after an unsuccessful -> successful login
    flash.clear
  
    if @session.authenticated?
      if user.full_name.blank? || user.phone_number.blank?
        redirect_to edit_user_path(user.slug)
      else
        redirect_to(params[:return_to] || root_path)
      end
    else
      # user failed webauthn & has 
      redirect_to login_code_user_session_path(@session), status: :temporary_redirect
    end
  rescue Errors::InvalidLoginCode, Errors::BrowserMismatch => e
    message = case e
              when Errors::InvalidLoginCode
                "Invalid login code!"
              when Errors::BrowserMismatch
                "Looks like this isn't the browser that requested that code!"
              end
  
    flash.now[:error] = message
    # Propagate the to the login_code page on invalid code
    @user_id = params[:user_id]
    @email = params[:email]
    @force_use_email = params[:force_use_email]
    initialize_sms_params
    return render :login_code, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors&.messages&.values&.flatten&.join(". ")
    redirect_to auth_users_path
  end
  
  def initialize_sms_params
    return if @force_use_email || @session.authenticated_with_sms?
  
    user = User.find_by(email: @email)
    if user&.use_sms_auth || @session.authenticated_with_email?
      @use_sms_auth = true
      @phone_last_four = user.phone_number.last(4)
    end
  end
end