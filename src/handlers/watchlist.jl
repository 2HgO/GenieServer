function getWatchlist(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))

	id, ok = utils.safe_bson_id(payload(:userID))
	!ok && throw(errors.ValidationError("Invalid user id"))

	watchlist = controllers.getUserWatchlist(id)
	utils.ok_response(context, 200, JSON2.write(watchlist, redact=true), message="Watchlist retrieved successfully")
end

function addMovieToUserWatchlist(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))

	id, ok = utils.safe_bson_id(payload(:movieID))
	!ok && throw(errors.ValidationError("Invalid movie id"))

	controllers.addMovieToUserWatchlist(context["user"]._id, id)
	utils.ok_response(context, 201, message="Movie added successfully")
end

function removeMovieFromUserWatchlist(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))

	id, ok = utils.safe_bson_id(payload(:movieID))
	!ok && throw(errors.ValidationError("Invalid movie id"))

	controllers.removeMovieFromUserWatchlist(context["user"]._id, id)
	utils.ok_response(context, 200, message="Movie removed successfully")
end
