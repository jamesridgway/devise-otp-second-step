class ReplaceEncryptedOtpSecretWithOtpSecret < ActiveRecord::Migration[7.0]
  # devise-two-factor 5 replaced the three attr_encrypted-backed columns with a
  # single otp_secret column held as a Rails encrypted attribute.
  #
  # This drops the legacy columns outright, which is safe here because the demo
  # database is seeded from scratch. An application with real users must first
  # copy each secret across using the #legacy_otp_secret reader described in
  # https://github.com/devise-two-factor/devise-two-factor/blob/main/UPGRADING.md
  # otherwise every enrolled user is locked out of their authenticator.
  def change
    add_column :users, :otp_secret, :string

    remove_column :users, :encrypted_otp_secret, :string
    remove_column :users, :encrypted_otp_secret_iv, :string
    remove_column :users, :encrypted_otp_secret_salt, :string
  end
end
