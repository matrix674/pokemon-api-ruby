# pokemon-api-ruby

This is a test API that expose a csv file (pokemon.csv) through a JSON RESTful API, listening on port 3000, and allow to read, update, create and delete pokemons. A paginated pokemon catalog is also available.

Compilation
------------

    bundle install

Start server
------------

    rails server

API routes
------------

    GET - /getPokemon/:name

Returns the stats of the pokemon with the specified name.

    POST - /createPokemon
    
Create a new pokemon. The pokemon name must not already exists. The body must contain a JSON object similar to the one returned from /getPokemon
    
    PUT - /updatePokemon/:name
    
Updates an existing pokemon. The body must contain a JSON object similar to the one returned from /getPokemon with the values that need to be updated
    
    DELETE - /deletePokemon/:name
    
Delete an existing pokemon.
    
    GET - /getPokemonCatalog/:page
    
Returns a list of pokemon. Each page (starting at 0) contains up to 50 pokemons.
