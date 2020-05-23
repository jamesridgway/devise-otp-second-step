Rails.application.routes.draw do
  devise_for :users, controllers: {
      passwords: 'passwords',
      registrations: 'registrations',
      sessions: 'sessions'
  }
  root 'welcome#index'
end
