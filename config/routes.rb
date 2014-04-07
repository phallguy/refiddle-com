RefiddleCom::Application.routes.draw do

  resources :fiddles, path: "/", except: :index

  root to: "fiddles#new"

end
