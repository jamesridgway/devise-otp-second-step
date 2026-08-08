require 'rails_helper'

feature 'User can disable OTP', js: true do
  scenario 'When OTP two-factor is enabled' do
    # Given I am a user that has OTP two-factor authentication enabled
    user = create(:user, :with_otp)
    login_as(user)

    # And I visit the account settings page
    visit edit_user_registration_path

    # And I expect to be able to disable OTP-based two-factor authentication
    expect(page).to have_content('Two factor authentication is enabled.')
    expect(page).to have_link('Disable Two Factor Authentication')

    # And I click the disable link and confirm with my password
    click_link('Disable Two Factor Authentication')
    fill_in 'Enter your current password', with: 'letmein'
    click_button 'Disable Two Factor Authentication'

    # Then I expect two-factor authentication to be disabled
    expect(page).to have_content('Two factor authentication is NOT enabled.')
    expect(page).to have_link('Enable Two Factor Authentication')
    expect(user.reload.otp_required_for_login).to be false
  end

  scenario 'The wrong password leaves two-factor enabled' do
    user = create(:user, :with_otp)
    login_as(user)

    visit confirm_disable_two_factor_settings_path
    fill_in 'Enter your current password', with: 'not-my-password'
    click_button 'Disable Two Factor Authentication'

    expect(page).to have_content('Incorrect password')
    expect(user.reload.otp_required_for_login).to be true
    expect(user.otp_secret).to be_present
  end
end
