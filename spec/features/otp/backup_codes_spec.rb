require 'rails_helper'

feature 'Backup codes' do
  scenario 'are shown once when two factor is enabled' do
    user = create(:user)
    login_as(user)

    visit new_two_factor_settings_path
    user.reload

    fill_in 'Code', with: user.otp(user.otp_secret).at(Time.now)
    fill_in 'Enter your current password', with: 'letmein'
    click_button 'Confirm and Enable Two Factor'

    expect(page).to have_content('Keep these backup codes safe')
    expect(user.reload.otp_backup_codes).to be_present

    # A refresh must not redisplay them, and must not mint a new set.
    stored = user.otp_backup_codes
    visit edit_two_factor_settings_path

    expect(page).to have_content('You have already seen your backup codes.')
    expect(user.reload.otp_backup_codes).to eq stored
  end

  scenario 'are not minted by merely fetching the page' do
    # Two factor on, no codes issued yet. Fetching the page used to generate and
    # save a set as a side effect of a GET, so a prefetch or a crawler could
    # burn the one-shot display before the user ever saw it.
    user = create(:user)
    user.update!(otp_secret: User.generate_otp_secret, otp_required_for_login: true)
    login_as(user)

    visit edit_two_factor_settings_path

    expect(user.reload.otp_backup_codes).to be_blank
    expect(page).to_not have_content('Keep these backup codes safe')
  end

  scenario 'are stored as digests rather than in the clear' do
    user = create(:user, :with_otp)
    codes = user.generate_otp_backup_codes!
    user.save!

    expect(user.reload.otp_backup_codes).to_not include(*codes)
    expect(user.otp_backup_codes.first).to start_with('$2a$')
  end
end
