function createUser!(user::models.User)
	push!(db.collections.User, user)
end

function getUser(id::BSONObjectId) :: models.User
	pipeline = [
		Dict(
			"\$match" => Dict(
				"_id" => id
			)
		),
		Dict(
			"\$lookup" => Dict(
				"from" => "categories",
				"localField" => "likes",
				"foreignField" => "_id",
				"as" => "likes"
			)
		),
		Dict(
			"\$limit" => 1
		)
	]
	res::Array{models.User} = aggregate(db.collections.User, BSON(pipeline), models.User) 
	length(res) != 1 && throw(errors.NotFoundError("user not found"))
	return res[1]
end

function getUserByEmail(email::String) :: models.User
	pipeline = [
		Dict(
			"\$match" => Dict(
				"email" => email
			)
		),
		Dict(
			"\$lookup" => Dict(
				"from" => "categories",
				"localField" => "likes",
				"foreignField" => "_id",
				"as" => "likes"
			)
		),
		Dict(
			"\$limit" => 1
		)
	]
	res::Array{models.User} = aggregate(db.collections.User, BSON(pipeline), models.User) 
	length(res) != 1 && throw(errors.NotFoundError("user not found"))
	return res[1]
end

function getUsers(page::Int, limit::Int) :: Tuple{Array{models.User}, UInt}
	pipeline = [
		Dict(
			"\$lookup" => Dict(
				"from" => "categories",
				"localField" => "likes",
				"foreignField" => "_id",
				"as" => "likes",
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
	res::Array{models.User} = aggregate(db.collections.User, BSON(pipeline), models.User)
	count::UInt = length(db.collections.User)
	return res, count
end

function searchUsers(query::String, page::Int, limit::Int) :: Tuple{Array{models.User}, UInt}
	throw(errors.NotImplementedError("no time"))
end

function updateUser(id::BSONObjectId, update::models.User) :: models.User
	throw(errors.NotImplementedError("no time"))
end

function deleteUser(id::BSONObjectId) :: models.User
	throw(errors.NotImplementedError("no time"))
end
