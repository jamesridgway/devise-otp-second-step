require 'rails_helper'

feature 'User can view account settings' do
  scenario 'As a user without OTP, I can enable OTP' do
    # Given I am a user that does not have OTP two-factor authentication enabled
    user = create(:user)
    login_as(user)

    # And I visit the account settings page
    visit edit_user_registration_path

    # Then I expect to be able to enable OTP-based two-factor authentication
    expect(page).to have_content('Two factor authentication is NOT enabled.')
    expect(page).to have_link('Enable Two Factor Authentication')
  end
  scenario 'As a user with OTP, I can disable OTP' do
    # Given I am a user that has OTP two-factor authentication enabled
    user = create(:user, :with_otp)
    login_as(user)

    # And I visit the account settings page
    visit edit_user_registration_path

    # Then I expect to be able to disable OTP-based two-factor authentication
    expect(page).to have_content('Two factor authentication is enabled.')
    expect(page).to have_link('Disable Two Factor Authentication')
  end
end
