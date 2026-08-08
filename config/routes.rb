Rails.application.routes.draw do
  devise_for :users, controllers: {
      passwords: 'passwords',
      registrations: 'registrations',
      sessions: 'sessions'
  }
  resource :two_factor_settings, except: [:show] do
    # Turning two-factor off asks for the password first, so it needs a page of
    # its own rather than a bare DELETE link.
    get :confirm_disable
  end
  root 'welcome#index'
end
