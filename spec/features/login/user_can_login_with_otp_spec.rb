require 'rails_helper'

feature 'User with OTP two factor enabled' do
  scenario 'cannot login without a valid OTP' do
    # Given I am a user that has OTP two factor authentication enabled
    user = create(:user, :with_otp)

    # And I enter my username and password
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'letmein'
    click_button 'Login'

    # I expect to see an error message
    expect(page).to have_content("Invalid Email or password.")
  end
  scenario 'can login when providing a valid OTP' do
    # Given I am a user that has OTP two factor authentication enabled
    user = create(:user, :with_otp)

    # And I enter my username and password
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'letmein'
    fill_in 'OTP', with: user.current_otp
    click_button 'Login'

    # I expect to be successfully logged in and taken to the dashboard
    expect(current_path).to eq(root_path)
    expect(page).to have_content("You are currently logged in as #{user.email}.")
  end
end
