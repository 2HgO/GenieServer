function createMovie!(movie::models.Movie)
	push!(db.collections.Movie, movie)
end

function deleteMovie(id::BSONObjectId) :: models.Movie
	throw(errors.NotImplementedError("no time"))
end

function getMovie(id::BSONObjectId) :: models.Movie
	throw(errors.NotImplementedError("no time"))
end

function getMovies(page::Int, limit::Int) :: Tuple{Array{models.Movie}, UInt}
	throw(errors.NotImplementedError("no time"))
end

function getMoviesByCategory(categoryId::BSONObjectId, page::Int, limit::Int) :: Tuple{Array{models.Movie}, UInt}
	throw(errors.NotImplementedError("no time"))
end

function serachMovies(query::String, page::Int, limit::Int) :: Tuple{Array{models.Movie}, UInt}
	throw(errors.NotImplementedError("no time"))
end