function createCategory!(category::models.Category)
	throw(errors.NotImplementedError("no time"))
end

function deleteCategory(id::BSONObjectId) :: models.Category
	throw(errors.NotImplementedError("no time"))
end

function getCategory(id::BSONObjectId) :: models.Category
	throw(errors.NotImplementedError("no time"))
end

function getCategories(page::Int, limit::Int) :: Tuple{Array{models.Category}, UInt}
	throw(errors.NotImplementedError("no time"))
end

function searchCategories(query::String, page::Int, limit::Int) :: Tuple{Array{models.Category}, UInt}
	throw(errors.NotImplementedError("no time"))
end