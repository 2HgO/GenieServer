function getCategory(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	
	id, ok = utils.safe_bson_id(payload(:categoryID))
	!ok && throw(errors.ValidationError("Invalid category id"))

	category = controllers.getCategory(id)
	utils.ok_response(context, 200, JSON2.write(category), message="Category retrieved successfully")
end

function getCategories(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	
	page::Int = parse(Int, getpayload(:page, "1"))
	limit::Int = parse(Int, getpayload(:limit, "200"))
	(page < 1 || limit < 1) && throw(errors.ValidationError("Invalid filter value(s)"))

	categories, count = controllers.getCategories(page, limit)
	utils.ok_response(context, 200, JSON2.write(categories), message="Categories retrieved successfully", count=count)
end

function deleteCategory(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	
	id, ok = utils.safe_bson_id(payload(:categoryID))
	!ok && throw(errors.ValidationError("Invalid category id"))

	category = controllers.deleteCategory(id)
	utils.ok_response(context, 200, JSON2.write(category), message="Category deleted successfully")
end

function createCategory(context::Dict{String,Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))

	jsonpayload() === nothing && throw(errors.ValidationError("Invalid request body"))
	category::models.Category = JSON2.read(rawpayload(), models.Category)
	
	controllers.createCategory!(category)
	utils.ok_response(context, 201, JSON2.write(category), message="Category created successfully")
end

function searchCategories(context::Dict{String,Any})
	throw(errors.NotImplementedError())
end
