module AuthenticateWithOtpTwoFactor
  extend ActiveSupport::Concern


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
    # Rendered in response to the POST to sessions#create. Turbo discards the
    # body of a 200 on a form submission, so the second-factor prompt has to
    # come back as 422 to be shown at all.
    render 'devise/sessions/two_factor', status: :unprocessable_entity
  end

  def authenticate_user_with_otp_two_factor(user)
    if valid_otp_attempt?(user)
      # Remove any lingering user data from login
      session.delete(:otp_user_id)

      reset_failed_attempts(user)
      remember_me(user) if user_params[:remember_me] == '1'
      user.save!
      sign_in(user, event: :authentication)
    elsif register_failed_otp_attempt(user)
      # The failed guess locked the account, so stop offering the prompt.
      session.delete(:otp_user_id)
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

    @find_user =
      if session[:otp_user_id]
        User.find(session[:otp_user_id])
      elsif user_params[:email]
        User.find_by(email: user_params[:email])
      end
  end

  def otp_two_factor_enabled?
    find_user&.otp_required_for_login
  end

end
