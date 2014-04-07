RefiddleCom::Application.routes.draw do

  resources :refiddles, except: :index, controller: :refiddles do
    resources :forks, only: [:create,:index]
    resources :revisions, only: [:index,:show] do
      member do
        post :revert
      end
    end
  end

  post "regex/replace/:flavor" => "play#replace", as: :regex_replace
  post "regex/evaluate/:flavor" => "play#evaluate", as: :regex_evaluate

  rapped_routes

  root to: "refiddles#new"

end
