class SessionsController < Devise::SessionsController
  include AuthenticateWithOtpTwoFactor
  layout 'login'

  # The locked check matters: this callback runs ahead of Warden and verifies
  # the password itself, so without it a locked account still reveals whether a
  # submitted password was right by whether the OTP prompt appears. Skipping the
  # callback lets the request fall through to devise, which refuses outright.
  prepend_before_action :authenticate_with_otp_two_factor,
                        if: -> { action_name == 'create' && otp_two_factor_enabled? && !user_locked? }

  protect_from_forgery with: :exception, prepend: true, except: :destroy

end