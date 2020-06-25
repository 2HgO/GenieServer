function createUser(context::Dict{String, Any})
	jsonpayload() === nothing && throw(errors.ValidationError("Invalid request body"))
	user::models.User = JSON2.read(rawpayload(), models.User)
	
	controllers.createUser!(user)
	utils.ok_response(context, 201, JSON2.write(user, redact=true), message="User created successfully")
end

function updateUser(context::Dict{String, Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	
	jsonpayload() === nothing && throw(errors.ValidationError("Invalid request body"))
	update::models.User = JSON2.read(rawpayload(), models.User)
	
	updatedUser = controllers.updateUser(context["user"]._id, update)
	utils.ok_response(context, 200, JSON2.write(user, redact=true), message="User updated successfully")
end

function deleteUser(context::Dict{String, Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	
	user = controllers.deleteUser(context["user"]._id)
	utils.ok_response(context, 200, JSON2.write(user, redact=true), message="User deleted successfully")
end

function getUser(context::Dict{String, Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	
	id, ok = utils.safe_bson_id(payload(:userID))
	!ok && throw(errors.ValidationError("Invalid user id"))

	user = (context["user"]._id == id) ? context["user"] : controllers.getUser(id)
	utils.ok_response(context, 200, JSON2.write(user, redact=true), message="User retrieved successfully")
end

function getUsers(context::Dict{String, Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	
	page::Int = parse(Int, getpayload(:page, "1"))
	limit::Int = parse(Int, getpayload(:limit, "200"))
	(page < 1 || limit < 1) && throw(errors.ValidationError("Invalid filter value(s)"))

	users, count = controllers.getUsers(page, limit)
	utils.ok_response(context, 200, JSON2.write(users, redact=true), message="Users retrieved successfully", count=count)
end

function searchUsers(context::Dict{String, Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	
	page::Int = parse(Int, getpayload(:page, "1"))
	limit::Int = parse(Int, getpayload(:limit, "200"))
	query::String = string(getpayload(:query, ""))
	(page < 1 || limit < 1) && throw(errors.ValidationError("Invalid filter value(s)"))

	users, count = controllers.searchUsers(query, page, limit)
	utils.ok_response(context, 200, JSON2.write(users, redact=true), message="Users retrieved successfully", count=count)
end