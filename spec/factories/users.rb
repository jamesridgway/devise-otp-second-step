FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@example.com" }
    password { 'letmein' }
    trait :with_otp do
      otp_required_for_login { true }

      after(:build) do |user, _evaluator|
        user.otp_secret = User.generate_otp_secret
        user.otp_plain_backup_codes = user.generate_otp_backup_codes!
      end
    end
  end
end
