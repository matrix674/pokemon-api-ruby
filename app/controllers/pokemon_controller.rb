class PokemonController < ApplicationController
	include DataHandler

	def initialize
		init_data_handler
		super
	end

  def get
		pokemon = get_pokemon(params[:pok_name])
		if pokemon != nil
			render :status => :ok, :body => pokemon.to_json
		else
			render :status => :not_found, :body => 'Pokemon not found.'
		end
  end

	def create
		validation_res = validate_data_for_create(params)
		if (validation_res[:result])
			if (get_pokemon(params[:Name]) != nil)
				render status: :conflict, :body => 'A pokemon with that name already exists.'
			else
				result = create_new_pokemon(params)
				render :status => :no_content 
			end
		else
			render :status => :bad_request, :body => validation_res[:message]
		end
	end

	def delete
		if get_pokemon(params[:pok_name])
			delete_data_entry(params[:pok_name])
			render :status => :no_content 
		else
			render status: :not_found, :body => 'Pokemon not found.'
		end
	end

	def update
		if get_pokemon(params[:pok_name])
			validation_res = validate_data_for_update(params)
			if (validation_res[:result])
				if params[:Name] != nil && get_pokemon(params[:Name]) != nil
					render status: :conflict, :body => 'A pokemon with the new specified name already exists.'
				else
					update_pokemon(params[:pok_name], params)
					render :status => :no_content 
				end
			else
				puts validation_res[:message]
				render status: :bad_request, :body => validation_res[:message]
			end
		else
			render status: :not_found, :body => 'Pokemon not found.'
		end
	end

	def get_catalog
		page = to_int(params[:page])
		if page != nil
			result = get_catalog_page(page)
			render :status => :ok, :body => result.to_json
		else
			render status: :bad_request, :body => 'The URI attribute page must be an integer.'
		end
	end
end
