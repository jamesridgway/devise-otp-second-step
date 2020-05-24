class SessionsController < Devise::SessionsController
  layout 'login'

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  end

end