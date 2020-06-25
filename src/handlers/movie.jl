function getMovie(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	
	id, ok = utils.safe_bson_id(payload(:movieID))
	!ok && throw(errors.ValidationError("Invalid movie id"))

	movie = controllers.getMovie(id)
	utils.ok_response(context, 200, JSON2.write(movie), message="Movie retrieved successfully")
end

function getMoviesByCategory(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))

	id, ok = utils.safe_bson_id(payload(:categoryID))
	!ok && throw(errors.ValidationError("Invalid category id"))
	
	page::Int = parse(Int, getpayload(:page, "1"))
	limit::Int = parse(Int, getpayload(:limit, "200"))
	(page < 1 || limit < 1) && throw(errors.ValidationError("Invalid filter value(s)"))

	movies, count = controllers.getMoviesByCategory(id, page, limit)
	utils.ok_response(context, 200, JSON2.write(movies), message="Movies retrieved successfully", count=count)
end

function deleteMovie(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	
	id, ok = utils.safe_bson_id(payload(:movieID))
	!ok && throw(errors.ValidationError("Invalid movie id"))

	movie = controllers.deleteMovie(id)
	utils.ok_response(context, 200, JSON2.write(movie), message="Movie deleted successfully")
end

function createMovie(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))

	jsonpayload() === nothing && throw(errors.ValidationError("Invalid request body"))
	movie::models.Movie = JSON2.read(rawpayload(), models.Movie)
	
	controllers.createMovie!(movie)
	utils.ok_response(context, 201, JSON2.write(movie), message="Movie created successfully")
end

function getMovies(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	
	page::Int = parse(Int, getpayload(:page, "1"))
	limit::Int = parse(Int, getpayload(:limit, "200"))
	(page < 1 || limit < 1) && throw(errors.ValidationError("Invalid filter value(s)"))

	movies, count = controllers.getMovies(page, limit)
	utils.ok_response(context, 200, JSON2.write(movies), message="Movies retrieved successfully", count=count)
end

function searchMovies(context::Dict{String,Any})
	throw(errors.NotImplementedError())
end
