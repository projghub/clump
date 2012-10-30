Clump::Application.routes.draw do
  resources :leads, only: [:index, :show]

  root :to => 'leads#index'
end
