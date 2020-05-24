class RegistrationsController < Devise::RegistrationsController
  layout "login", only: [:new]
end