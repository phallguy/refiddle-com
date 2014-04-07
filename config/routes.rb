RefiddleCom::Application.routes.draw do

  resources :refiddles, except: :index, controller: :refiddles do
    member do 
      get :revisions
    end

    resources :forks, only: [:create,:index]
  end

  get "regex/replace/:flavor" => "play", as: :regex_replace
  get "regex/evaluate/:flavor" => "play", as: :regex_evaluate

  rapped_routes

  root to: "refiddles#new"

end
