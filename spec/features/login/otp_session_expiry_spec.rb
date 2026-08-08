require 'rails_helper'

feature 'Half-authenticated session' do
  def start_login(user)
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'letmein'
    click_button 'Login'
  end

  scenario 'expires, so an abandoned code prompt cannot be used later' do
    user = create(:user, :with_otp)
    start_login(user)
    expect(page).to have_content('Two Factor Authentication')

    travel(AuthenticateWithOtpTwoFactor::OTP_PENDING_TIMEOUT + 1.minute) do
      fill_in 'OTP', with: user.current_otp
      click_button 'Login'

      expect(page).to_not have_content('Dashboard')
      expect(page).to have_content('Login')
    end
  end

  scenario 'still works well within the timeout' do
    user = create(:user, :with_otp)
    start_login(user)

    travel(1.minute) do
      fill_in 'OTP', with: user.current_otp
      click_button 'Login'

      expect(page).to have_content('Dashboard')
    end
  end

  scenario 'survives the account being deleted without erroring' do
    user = create(:user, :with_otp)
    start_login(user)
    expect(page).to have_content('Two Factor Authentication')

    user.destroy

    fill_in 'OTP', with: '123456'
    click_button 'Login'

    # Previously User.find raised RecordNotFound and the user got an error page.
    expect(page).to have_content('Login')
    expect(page).to_not have_content('RecordNotFound')
  end
end
