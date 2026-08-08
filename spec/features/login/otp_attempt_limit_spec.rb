require 'rails_helper'

feature 'One-time code attempt limit' do
  def sign_in_with_password(user)
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'letmein'
    click_button 'Login'
  end

  def submit_code(code)
    fill_in 'OTP', with: code
    click_button 'Login'
  end

  scenario 'wrong codes eventually lock the account rather than being unlimited' do
    user = create(:user, :with_otp)
    sign_in_with_password(user)
    expect(page).to have_content('Two Factor Authentication')

    (User.maximum_attempts - 1).times do |i|
      submit_code(format('%06d', i))
      expect(page).to have_content('Invalid two-factor code.')
    end

    submit_code('999999')

    expect(page).to have_content('Your account is locked.')
    expect(user.reload.access_locked?).to be true
  end

  scenario 'a correct code clears the failed attempts it took to get there' do
    user = create(:user, :with_otp)
    sign_in_with_password(user)

    submit_code('000000')
    expect(page).to have_content('Invalid two-factor code.')
    expect(user.reload.failed_attempts).to eq 1

    submit_code(user.current_otp)

    expect(page).to have_content('Dashboard')
    expect(user.reload.failed_attempts).to eq 0
  end

  scenario 'a locked account cannot keep guessing by starting a fresh session' do
    user = create(:user, :with_otp)
    sign_in_with_password(user)
    User.maximum_attempts.times { |i| submit_code(format('%06d', i)) }
    expect(user.reload.access_locked?).to be true

    # A session-local counter would be defeated by simply signing in again.
    sign_in_with_password(user)

    expect(page).to have_content('Your account is locked.')
    expect(page).to_not have_content('Two Factor Authentication')
  end
end
