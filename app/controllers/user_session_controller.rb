class UserSessionController < ApplicationController
  def choose_login_preference
    @email = session[:auth_email]
    @user = User.find_by_email(@email)
    @return_to = params[:return_to]
    return redirect_to auth_users_path if @email.nil?
  
    session.delete :login_preference
  end
  
  def set_login_preference
    @email = params[:email]
    remember = params[:remember] == "1"
  
    case params[:login_preference]
    when "email"
      session[:login_preference] = "email" if remember
      redirect_to login_code_users_path, status: :temporary_redirect
    when "webauthn"
      # This should never happen, because WebAuthn auth is handled on the frontend
      redirect_to choose_login_preference_users_path
    end
  end
  
  # post to request login code
  def login_code
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
  
    if resp[:login_code]
      cookies.signed[:"browser_token_#{resp[:login_code].id}"] = { value: resp[:browser_token], expires: LoginCode::EXPIRATION.from_now }
    end
  
    @user_id = resp[:id]
  
    @webauthn_available = User.find_by(email: @email)&.webauthn_credentials&.any?
  
    render status: :unprocessable_entity
  
  rescue ActionController::ParameterMissing
    flash[:error] = "Please enter an email address."
    redirect_to auth_users_path
  end
  
  def webauthn_options
    return head :not_found if !params[:email]
  
    session[:auth_email] = params[:email]
  
    return head :not_found if params[:require_webauthn_preference] && session[:login_preference] != "webauthn"
  
    user = User.find_by(email: params[:email])
  
    return head :not_found if !user || user.webauthn_credentials.empty?
  
    options = WebAuthn::Credential.options_for_get(
      allow: user.webauthn_credentials.pluck(:webauthn_id),
      user_verification: "discouraged"
    )
  
    session[:webauthn_challenge] = options.challenge
  
    render json: options
  end
  
  def webauthn_auth
    user = User.find_by(email: params[:email])
  
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
  
      sign_in(user:, fingerprint_info:, webauthn_credential: stored_credential)
  
      redirect_to(params[:return_to] || root_path)
  
    rescue WebAuthn::SignCountVerificationError, WebAuthn::Error => e
      redirect_to auth_users_path, flash: { error: "Something went wrong." }
    rescue ActiveRecord::RecordInvalid => e
      redirect_to auth_users_path, flash: { error: e.record.errors&.full_messages&.join(". ") }
    end
  end
  
  # post to exchange auth token for access token
  def exchange_login_code
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
  
    sign_in(user:, fingerprint_info:)
  
    # Clear the flash - this prevents the error message showing up after an unsuccessful -> successful login
    flash.clear
  
    if user.full_name.blank? || user.phone_number.blank?
      redirect_to edit_user_path(user.slug)
    else
      redirect_to(params[:return_to] || root_path)
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
end