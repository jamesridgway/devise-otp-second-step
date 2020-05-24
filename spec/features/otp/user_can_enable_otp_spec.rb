require 'rails_helper'

feature 'User can enable OTP', js: true do
  scenario 'When OTP two-factor is not already enabled' do
    otp_secret = User.generate_otp_secret
    allow(User).to receive(:generate_otp_secret).and_return(otp_secret)

    # Given I am a user that does not have OTP two-factor authentication enabled
    user = create(:user)
    login_as(user)

    # And I visit the account settings page
    visit edit_user_registration_path

    # And I expect to be able to disable OTP-based two-factor authentication
    expect(page).to have_content('Two factor authentication is NOT enabled.')
    expect(page).to have_link('Enable Two Factor Authentication')

    # And I click the disable link
    click_link('Enable Two Factor Authentication')
    user.reload

    # And I enter a valid OTP code and password
    fill_in 'Code', with: user.otp(otp_secret).at(Time.now)
    fill_in 'Enter your current password', with: 'letmein'
    click_button 'Confirm and Enable Two Factor'

    # Then I expect to see the backup codes
    user.reload
    expect(page).to have_content('Keep these backup codes safe in case you lose access to your authenticator app:')

    # And then I expect two-factor authentication to be disabled
    click_link('Return to account settings')
    expect(page).to have_content('Two factor authentication is enabled.')
    expect(page).to have_link('Disable Two Factor Authentication')
  end
end
