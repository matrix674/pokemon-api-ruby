require "test_helper"

class PokemonControllerTest < ActionDispatch::IntegrationTest
  test "should get getPokemon" do
    get pokemon_getPokemon_url
    assert_response :success
  end
end
