function createCategory!(category::models.Category)
	push!(db.collections.Category, category)
end

function deleteCategory(id::BSONObjectId) :: models.Category
	return delete_one(db.collections.Category, BSON("_id" => id), models.Category)
end

function getCategory(id::BSONObjectId) :: models.Category
	return find_one(db.collections.Category, BSON("_id" => id), models.Category)
end

function getCategories(page::Int, limit::Int) :: Tuple{Array{models.Category}, UInt}
	pipeline = [
		Dict(
			"\$sort" => Dict(
				"createdAt" => -1
			)
		),
		Dict(
			"\$skip" => limit*(page - 1),
		),
		Dict(
			"\$limit" => limit,
		),
	]
	res::Array{models.Category} = aggregate(db.collections.Category, BSON(pipeline), models.Category)
	count::UInt = length(db.collections.Category)
	return res, count
end

function searchCategories(query::String, page::Int, limit::Int) :: Tuple{Array{models.Category}, UInt}
	throw(errors.NotImplementedError("no time"))
end