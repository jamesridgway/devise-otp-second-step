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

    # And I click the disable link
    click_link('Disable Two Factor Authentication')
    page.accept_alert 'Are you sure you want to disable two factor authentication?'

    # Then I expect two-factor authentication to be disabled
    expect(page).to have_content('Two factor authentication is NOT enabled.')
    expect(page).to have_link('Enable Two Factor Authentication')
  end
end
