Rails.application.routes.draw do
  get 'getPokemon/:pok_name', to: "pokemon#get"
	get 'getPokemonCatalog/:page', to: "pokemon#get_catalog"
	post 'createPokemon', to: "pokemon#create"
	put 'updatePokemon/:pok_name', to: "pokemon#update"
	delete 'deletePokemon/:pok_name', to: "pokemon#delete"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
