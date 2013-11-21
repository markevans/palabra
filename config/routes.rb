Palabra::Application.routes.draw do
  resource :search, only: [:edit, :show]
  get "/song" => 'songs#show', as: :song
  root to: 'searches#edit'
end
