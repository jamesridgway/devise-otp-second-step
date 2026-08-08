module AuthenticateWithOtpTwoFactor
  extend ActiveSupport::Concern

  # How long the half-authenticated state between the password and the code is
  # allowed to sit around. Without a bound it lasts as long as the session, and
  # a browser left on the code prompt stays one guess away from signing in.
  OTP_PENDING_TIMEOUT = 5.minutes

  def authenticate_with_otp_two_factor
    user = self.resource = find_user

    if user_params[:otp_attempt].present? && session[:otp_user_id]
      authenticate_user_with_otp_two_factor(user)
    elsif user&.valid_password?(user_params[:password])
      prompt_for_otp_two_factor(user)
    end
  end

  private

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt]) ||
        user.invalidate_otp_backup_code!(user_params[:otp_attempt])
  end

  def prompt_for_otp_two_factor(user)
    @user = user

    session[:otp_user_id] = user.id
    session[:otp_pending_since] = Time.current.to_i
    # Rendered in response to the POST to sessions#create. Turbo discards the
    # body of a 200 on a form submission, so the second-factor prompt has to
    # come back as 422 to be shown at all.
    render 'devise/sessions/two_factor', status: :unprocessable_entity
  end

  def authenticate_user_with_otp_two_factor(user)
    if valid_otp_attempt?(user)
      # Remove any lingering user data from login
      clear_otp_session

      reset_failed_attempts(user)
      remember_me(user) if user_params[:remember_me] == '1'
      user.save!
      sign_in(user, event: :authentication)
    elsif register_failed_otp_attempt(user)
      # The failed guess locked the account, so stop offering the prompt.
      clear_otp_session
      redirect_to new_user_session_path, status: :see_other,
                                         alert: I18n.t('devise.failure.locked')
    else
      flash.now[:alert] = 'Invalid two-factor code.'
      prompt_for_otp_two_factor(user)
    end
  end

  ##
  # Count a wrong one-time code against the same budget devise's :lockable gives
  # wrong passwords, and lock the account once it is spent. Without this the
  # second factor can be guessed indefinitely: the code is only six digits, and
  # a session-local counter would not help because an attacker who already has
  # the password can simply start a new session.
  #
  # Returns true when this attempt locked the account.
  def register_failed_otp_attempt(user)
    return false unless user.respond_to?(:increment_failed_attempts)

    user.increment_failed_attempts
    user.lock_access! if user.failed_attempts >= user.class.maximum_attempts
    user.access_locked?
  end

  def reset_failed_attempts(user)
    return unless user.respond_to?(:unlock_access!)
    return unless user.failed_attempts.to_i.positive?

    user.unlock_access!
  end

  ##
  # Guarded with respond_to? so this concern still works in an application that
  # does not enable :lockable.
  def user_locked?
    user = find_user
    user.respond_to?(:access_locked?) && user.access_locked?
  end

  def user_params
    params.require(:user).permit(:email, :password, :remember_me, :otp_attempt)
  end

  def find_user
    return @find_user if defined?(@find_user)

    clear_expired_otp_session

    @find_user =
      if session[:otp_user_id]
        # find_by, not find: the account can be deleted between the password
        # step and the code step, and a stale session id should start the login
        # over rather than raise RecordNotFound at the user.
        User.find_by(id: session[:otp_user_id])
      elsif user_params[:email]
        User.find_by(email: user_params[:email])
      end
  end

  def clear_expired_otp_session
    return if session[:otp_user_id].blank?

    started = session[:otp_pending_since]
    return if started.present? && Time.at(started.to_i) > OTP_PENDING_TIMEOUT.ago

    clear_otp_session
  end

  def clear_otp_session
    session.delete(:otp_user_id)
    session.delete(:otp_pending_since)
  end

  def otp_two_factor_enabled?
    find_user&.otp_required_for_login
  end

end
