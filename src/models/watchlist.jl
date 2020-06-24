mutable struct Watchlist <: Model
	_id::Mongoc.BSONObjectId
	createdAt::Dates.DateTime
	updatedAt::Dates.DateTime
	user::Union{Mongoc.BSONObjectId, User}
	movies::Array{Union{Mongoc.BSONObjectId, Movie}}
end
