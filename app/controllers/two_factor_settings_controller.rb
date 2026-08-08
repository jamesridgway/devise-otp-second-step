class TwoFactorSettingsController < ApplicationController
  before_action :authenticate_user!

  def new
    if current_user.otp_required_for_login
      flash[:alert] = 'Two Factor Authentication is already enabled.'
      return redirect_to edit_user_registration_path
    end

    current_user.generate_two_factor_secret_if_missing!
  end

  def create
    unless current_user.valid_password?(enable_2fa_params[:password])
      flash.now[:alert] = 'Incorrect password'
      return render :new
    end

    if current_user.validate_and_consume_otp!(enable_2fa_params[:code])
      current_user.enable_two_factor!

      # Generated here rather than in #edit: a GET that mints fresh codes means
      # a browser prefetch, a crawler or an idle refresh silently invalidates
      # the ones the user has already written down. Handed to the next request
      # through the session, which is where one-shot plaintext belongs.
      session[:otp_backup_codes] = current_user.generate_otp_backup_codes!
      current_user.save!

      flash[:notice] = 'Successfully enabled two factor authentication, please make note of your backup codes.'
      redirect_to edit_two_factor_settings_path, status: :see_other
    else
      flash.now[:alert] = 'Incorrect Code'
      render :new
    end
  end

  def edit
    unless current_user.otp_required_for_login
      flash[:alert] = 'Please enable two factor authentication first.'
      return redirect_to new_two_factor_settings_path
    end

    # Shown exactly once: taken out of the session so a refresh cannot redisplay
    # them, and never re-derived, because only the digests are stored.
    @backup_codes = session.delete(:otp_backup_codes)

    return if @backup_codes.present?

    flash[:alert] = 'You have already seen your backup codes.'
    redirect_to edit_user_registration_path
  end

  def confirm_disable
    return if current_user.otp_required_for_login

    flash[:alert] = 'Two factor authentication is not enabled.'
    redirect_to edit_user_registration_path
  end

  # Removing the second factor is exactly the action an attacker who has stolen
  # a session wants, so it demands the password in the same way enabling it
  # does. Without that, a hijacked session silently strips the account back to
  # one factor.
  def destroy
    unless current_user.valid_password?(disable_2fa_params[:password])
      flash.now[:alert] = 'Incorrect password'
      return render :confirm_disable, status: :unprocessable_entity
    end

    if current_user.disable_two_factor!
      flash[:notice] = 'Successfully disabled two factor authentication.'
      redirect_to edit_user_registration_path, status: :see_other
    else
      flash[:alert] = 'Could not disable two factor authentication.'
      redirect_back fallback_location: root_path, status: :see_other
    end
  end

  private

  def enable_2fa_params
    params.require(:two_fa).permit(:code, :password)
  end

  def disable_2fa_params
    params.fetch(:two_fa, {}).permit(:password)
  end

end
