mutable struct Watchlist <: Model
	_id::Mongoc.BSONObjectId
	user::User
	movies::Array{Movie, 1}

	function Watchlist(;
		_id::Mongoc.BSONObjectId,
		user::User,
		movies::Array{Movie, 1},
		kwargs...
	)
		new(_id, user, movies)
	end
end

JSON2.@format Watchlist "keywordargs" begin
	_id => (;name=:_id)
	user => (;name=:user)
	movies => (;name=:movies)
end