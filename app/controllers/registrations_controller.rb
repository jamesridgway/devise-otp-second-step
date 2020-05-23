class RegistrationsController < Devise::RegistrationsController
  layout user_signed_in? ? 'application' : 'login'
end