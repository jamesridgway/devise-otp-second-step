Rails.application.routes.draw do
  devise_for :users, controllers: {
      passwords: 'passwords',
      registrations: 'registrations',
      sessions: 'sessions'
  }
  resource :two_factor_settings, except: [:index, :show]
  root 'welcome#index'
end
