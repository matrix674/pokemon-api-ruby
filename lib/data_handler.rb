module DataHandler
	require 'csv'
	@@initialized = false
	@@requireSorting = true
	@@entries_per_page = 50
	@@file_name = 'pokemon.csv'
	@@columns = {
		'No': {'formatFct': -> (context, value) {context.to_int(value)}, 'validationFct': -> (context, value) {context.validate_int(value, 1)}, 'invalidMsg': 'Attribute \'#\' must be an integer, greater than 1 and must not be null.'},
		'Name': {'validationFct': -> (context, value) {context.validate_string(value, 45)}, 'invalidMsg': 'Attribute \'Name\' must be a string of maximum 45 characters and must not be null or empty.'},
		'Type 1': {'validationFct': -> (context, value) {context.validate_string(value, 20)}, 'invalidMsg': 'Attribute \'Type 1\' must be a string of maximum 20 characters and must not be null or empty.'},
		'Type 2': {'validationFct': -> (context, value) {context.validate_string(value, 20, true)}, 'invalidMsg': 'Attribute \'Type 2\' must be a string of maximum 20 characters.'},
		'Total': {'formatFct': -> (context, value) {context.to_int(value)}, 'validationFct': -> (context, value) {context.validate_int(value, 1)}, 'invalidMsg': 'Attribute \'Total\' must be an integer, greater than 0 and must not be null.'},
		'HP': {'formatFct': -> context, (value) {context.to_int(value)}, 'validationFct': -> (context, value) {context.validate_int(value, 1)}, 'invalidMsg': 'Attribute \'HP\' must be an integer, greater than 0 and must not be null.'},
		'Attack': {'formatFct': -> (context, value) {context.to_int(value)}, 'validationFct': -> (context, value) {context.validate_int(value, 1)}, 'invalidMsg': 'Attribute \'Attack\' must be an integer, greater than 0 and must not be null.'},
		'Defense': {'formatFct': -> (context, value) {context.to_int(value)}, 'validationFct': -> (context, value) {context.validate_int(value, 1)}, 'invalidMsg': 'Attribute \'Defense\' must be an integer, greater than 0 and must not be null.'},
		'Sp. Atk': {'formatFct': -> (context, value) {context.to_int(value)}, 'validationFct': -> (context, value) {context.validate_int(value, 1)}, 'invalidMsg': 'Attribute \'Sp. Atk\' must be an integer, greater than 0 and must not be null.'},
		'Sp. Def': {'formatFct': -> (context, value) {context.to_int(value)}, 'validationFct': -> (context, value) {context.validate_int(value, 1)}, 'invalidMsg': 'Attribute \'Sp. Def\' must be an integer, greater than 0 and must not be null.'},
		'Speed': {'formatFct': -> (context, value) {context.to_int(value)}, 'validationFct': -> (context, value) {context.validate_int(value, 1)}, 'invalidMsg': 'Attribute \'Speed\' must be an integer, greater than 0 and must not be null.'},
		'Generation': {'formatFct': -> (context, value) {context.to_int(value)}, 'validationFct': -> (context, value) {context.validate_int(value, 1)}, 'invalidMsg': 'Attribute \'Generation\' must be an integer, greater than 0 and must not be null.'},
		'Legendary': {'formatFct': -> (context, value) {['True', 'true', true].include?(value)}, 'validationFct': -> (context, value) {context.validate_bool(value)}, 'invalidMsg': 'Attribute \'Legendary\' must be a boolean and must not be null.'}
	}
	@@keys = @@columns.keys
	@@pokemons = {}
	@@pokemonsArray = []

	def init_data_handler
		if @@initialized 
			return
		end
		csvData = CSV.parse(File.read('pokemon.csv'))
		parse_csv(csvData)
		@@initialized = true
	end

	def parse_csv(data)
		puts "Parsing CSV file"
		for i in 1 ... data.length
			entry = {}
			next if data[i].length < @@keys.length 
			for j in 0 ... @@keys.length
				key = @@keys[j]
				if @@columns[key].key?(:formatFct)
					entry[key] = @@columns[key][:formatFct].call(self, data[i][j])
				else 
					entry[key] = data[i][j]
				end
			end
			@@pokemons[entry[:Name]] = entry
		end
		refresh_pokemon_array
	end

	def write_csv
		@@requireSorting = true
		file_content = @@keys.join(',')
		@@pokemons.each do |name, pokemon|
			array = []
			@@keys.each do |key|
				array.push(pokemon[key] != nil ? pokemon[key] : '')
			end
			file_content += "\n#{array.join(',')}"
		end
		File.write(@@file_name, file_content)
	end

	def get_pokemon(name)
		return @@pokemons[name]
	end

	def delete_data_entry(name)
		@@pokemons.delete(name)
		write_csv
	end

	def get_catalog_page(page)
		return @@pokemonsArray[page * @@entries_per_page, @@entries_per_page]
	end

	def refresh_pokemon_array
		if @@requireSorting
			@@pokemonsArray = []
			@@pokemons.each do |key, value|
				@@pokemonsArray.push(value)
			end
			@@pokemonsArray.sort! { |a,b|
				if a[:No] < b[:No]
					return -1
				elsif a[:No] > b[:No]
					return 1
				else
					return a[:Name] <=> b[:Name]
				end
			}
			@@requireSorting = false
		end
	end

	def update_pokemon(name, data)
		entry = @@pokemons[name]
		update_entry_data(entry, data)
		if (data.key?(:Name))
			@@pokemons[data[:Name]] = entry
			@@pokemons.delete(name)
		end
		puts entry
		write_csv
	end

	def validate_data_for_update(data)
		useable_fields = 0
		message = []
		result = true
		data.each do |key, value|
			key = key.to_sym
			if @@columns.key?(key)
				useable_fields += 1
				if (!@@columns[key][:validationFct].call(self, value))
					result = false
					message.push(@@columns[key][:invalidMsg])
				end
			end
		end
		if (useable_fields <= 0)
			result = false;
			message.push("updatePokemon request body must contain at least 1 of the following fields: '#{@@keys.join(', ')}'.")
		end
		return {'result': result, 'message': message.join('\n')}
	end

	def create_new_pokemon(data)
		entry = {}
		update_entry_data(entry, data)
		@@pokemons[entry[:Name]] = entry
		write_csv
	end

	def update_entry_data(entry, data)
		data.each do |key, value|
			key = key.to_sym
			if (@@columns.key?(key))
				if (@@columns[key].key?('formatFct')) 
					entry[key] = @@columns[key][:formatFct].call(self, data[key])
				else
					entry[key] = data[key]
				end
			end
		end
	end

	def validate_data_for_create(data)
		result = true
		message = []
		@@columns.each do |key, value|
			if (!@@columns[key][:validationFct].call(self, data[key]))
				result = false
				message.push(@@columns[key][:invalidMsg])
			end
		end
		return {'result': result, 'message': message.join('\n')}
	end

	def validate_int(int, min=nil)
		return false if !int.is_a? Numeric 
		return false if min != nil && int < min
		return true 
	end

	def validate_bool(value)
		return [true, false].include?(value)
	end

	def validate_string(value, max_length, allow_null=false)
		return true if allow_null && (value == nil || value == '')
		return false if !allow_null && (value == nil || value == '')
		return false if !value.is_a?(String)
		return false if value.length > max_length
		return true
	end

	def to_int(value)
		begin
			return Integer(value)
		rescue
			return nil
		end
	end
end