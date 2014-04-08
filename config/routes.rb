RefiddleCom::Application.routes.draw do

  resources :refiddles, controller: :refiddles do
    resources :forks, only: [:create,:index]
    resources :revisions, only: [:index,:show] do
      member do
        post :revert
      end
    end
  end

  resources :tagged, only: [:index,:show], path: "tagged"
  resources :users
  resources :stackoverflow, only: [:index]
  get "stackoverflow/:id(/:title)" => "stackoverflow#show", as: :show_stackoverflow

  post "regex/replace/:flavor" => "play#replace", as: :regex_replace
  post "regex/evaluate/:flavor" => "play#evaluate", as: :regex_evaluate

  rapped_routes


  get "/:id" => "refiddles#show", as: :short
  root to: "refiddles#new"

end
