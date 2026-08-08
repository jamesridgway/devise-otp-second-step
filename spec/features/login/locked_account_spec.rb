require 'rails_helper'

feature 'Locked accounts' do
  # The two-factor callback runs ahead of Warden and checks the password
  # itself, so it has to repeat the lock check devise would otherwise do.
  # Without it a locked account answers differently for a right and a wrong
  # password, which tells an attacker when they have guessed it.
  scenario 'a locked user with OTP is refused even with the correct password' do
    user = create(:user, :with_otp, :locked)

    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'letmein'
    click_button 'Login'

    expect(page).to have_content('Your account is locked.')
    expect(page).to_not have_content('Two Factor Authentication')
  end

  scenario 'a locked user with OTP is refused with a wrong password, identically' do
    user = create(:user, :with_otp, :locked)

    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'not-the-password'
    click_button 'Login'

    expect(page).to have_content('Your account is locked.')
    expect(page).to_not have_content('Two Factor Authentication')
  end

  scenario 'a user whose lock has expired can log in again' do
    user = create(:user, :with_otp, :locked)
    user.update!(locked_at: (User.unlock_in + 1.minute).ago)

    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'letmein'
    click_button 'Login'

    expect(page).to have_content('Two Factor Authentication')
  end
end
