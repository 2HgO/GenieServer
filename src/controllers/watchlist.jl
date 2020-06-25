function addMovieToUserWatchlist(user::BSONObjectId, movie::BSONObjectId)
	(find_one(db.collections.User, BSON("_id" => user)) === nothing) && throw(errors.NotFoundError("user does not exist"))
	(find_one(db.collections.Movie, BSON("_id" => movie)) === nothing) && throw(errors.NotFoundError("movie does not exist"))
	if find_one(db.collections.Watchlist, BSON("user" => user)) === nothing
		push!(db.collections.Watchlist, BSON("user" => user, "movies" => [movie]))
	else
		(find_one(db.collections.Watchlist, BSON("user" => user, "movies" => movie)) !== nothing) && throw(errors.EntryExistsError("this movie is already in your watchlist"))
		update_one(db.collections.Watchlist, BSON("user" => user), BSON("\$addToSet" => BSON("movies" => movie)))
	end
end

function getUserWatchlist(user::BSONObjectId) :: models.Watchlist
	(find_one(db.collections.User, BSON("_id" => user)) === nothing) && throw(errors.NotFoundError("user does not exist"))
	pipeline = [
		Dict(
			"\$match" => Dict(
				"user" => user,
			),
		),
		Dict(
			"\$lookup" => Dict(
				"from" =>         "users",
				"localField" =>   "user",
				"foreignField" => "_id",
				"as" =>           "user",
			),
		),
		Dict(
			"\$unwind" => "\$user",
		),
		Dict(
			"\$lookup" => Dict(
				"from" =>         "movies",
				"localField" =>   "movies",
				"foreignField" => "_id",
				"as" =>           "movies",
			),
		),
		Dict(
			"\$lookup" => Dict(
				"from" =>         "categories",
				"localField" =>   "user.likes",
				"foreignField" => "_id",
				"as" =>           "user.likes",
			),
		),
		Dict(
			"\$unwind" => Dict(
				"path" => "\$movies",
				"preserveNullAndEmptyArrays" => true,
			),
		),
		Dict(
			"\$lookup" => Dict(
				"from" =>         "categories",
				"localField" =>   "movies.categories",
				"foreignField" => "_id",
				"as" =>           "movies.categories",
			),
		),
		Dict(
			"\$group" => Dict(
				"_id" =>       "\$_id",
				"user" =>      Dict("\$last" => "\$user"),
				"movies" =>    Dict("\$addToSet" => "\$movies"),
			),
		),
		Dict(
			"\$limit" => 1,
		),
	]

	res = aggregate(db.collections.Watchlist, BSON(pipeline), models.Watchlist)
	length(res) != 1 && throw(errors.NotFoundError("user has not created a watchlist"))

	return res[1]
end

function removeMovieFromUserWatchlist(user::BSONObjectId, movie::BSONObjectId)
	(find_one(db.collections.User, BSON("_id" => user)) === nothing) && throw(errors.NotFoundError("user does not exist"))
	(find_one(db.collections.Movie, BSON("_id" => movie)) === nothing) && throw(errors.NotFoundError("movie does not exist"))
	(find_one(db.collections.Watchlist, BSON("user" => user, "movies" => movie)) === nothing) && throw(errors.NotFoundError("this movie is not in your watchlist"))
	update_one(db.collections.Watchlist, BSON("user" => user), BSON("\$pull" => BSON("movies" => movie)))
end
