Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :projects, only: [] do
        resources :offsets, only: [ :create, :index ]
        resources :payouts, only: [ :index ]
      end
      resources :offsets, only: [] do
        resources :fulfillment_proofs, only: [ :create ]
      end
    end
  end
end
