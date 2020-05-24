require 'rails_helper'

feature 'User without any two factor can log in' do
  scenario 'Valid user without any two factor can login' do
    # Given I am a user that does not have 2fa enabled
    user = create(:user)

    # And I enter my username and password
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'letmein'
    click_button 'Login'

    # I expect to be successfully logged in and taken to the dashboard
    expect(current_path).to eq(root_path)
    expect(page).to have_content("You are currently logged in as #{user.email}.")
  end
end
