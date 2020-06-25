function createMovie!(movie::models.Movie)
	push!(db.collections.Movie, movie)
end

function deleteMovie(id::BSONObjectId) :: models.Movie
	return delete_one(db.collections.Movie, BSON("_id" => id), models.Movie)
end

function getMovie(id::BSONObjectId) :: models.Movie
	pipeline = [
		Dict(
			"\$match" => Dict(
				"_id" => id,
			),
		),
		Dict(
			"\$lookup" => Dict(
				"from" => "categories",
				"localField" => "categories",
				"foreignField" => "_id",
				"as" => "categories"
			)
		),
		Dict(
			"\$limit" => 1
		)
	]
	res::Array{models.Movie} = aggregate(db.collections.Movie, BSON(pipeline), models.Movie) 
	length(res) != 1 && throw(errors.NotFoundError("movie not found"))
	return res[1]
end

function getMovies(page::Int, limit::Int) :: Tuple{Array{models.Movie}, UInt}
	pipeline = [
		Dict(
			"\$lookup" => Dict(
				"from" => "categories",
				"localField" => "categories",
				"foreignField" => "_id",
				"as" => "categories",
			),
		),
		Dict(
			"\$sort" => Dict(
				"createdAt" => -1,
			),
		),
		Dict(
			"\$skip" => limit*(page - 1),
		),
		Dict(
			"\$limit" => limit,
		),
	]
	res::Array{models.Movie} = aggregate(db.collections.Movie, BSON(pipeline), models.Movie)
	count::UInt = length(db.collections.Movie)
	return res, count
end

function getMoviesByCategory(categoryId::BSONObjectId, page::Int, limit::Int) :: Tuple{Array{models.Movie}, UInt}
	pipeline = [
		Dict(
			"\$match" => Dict(
				"categories" => categoryId
			),
		),
		Dict(
			"\$lookup" => Dict(
				"from" => "categories",
				"localField" => "categories",
				"foreignField" => "_id",
				"as" => "categories",
			),
		),
		Dict(
			"\$sort" => Dict(
				"createdAt" => -1,
			),
		),
		Dict(
			"\$skip" => limit*(page - 1),
		),
		Dict(
			"\$limit" => limit,
		),
	]
	res::Array{models.Movie} = aggregate(db.collections.Movie, BSON(pipeline), models.Movie)
	count::UInt = length(db.collections.Movie)
	return res, count
end

function serachMovies(query::String, page::Int, limit::Int) :: Tuple{Array{models.Movie}, UInt}
	throw(errors.NotImplementedError("no time"))
end