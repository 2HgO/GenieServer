mutable struct Movie <: Model
	_id::Union{Mongoc.BSONObjectId, Nothing}
	createdAt::Union{Dates.DateTime, Nothing}
	updatedAt::Union{Dates.DateTime, Nothing}
	name::String
	categories::Array{Union{Mongoc.BSONObjectId, Category}, 1}
	release::Dates.Date

	function Movie(;
		_id::Union{Mongoc.BSONObjectId, Nothing} = nothing,
		createdAt::Union{Dates.DateTime, Nothing} = nothing,
		updatedAt::Union{Dates.DateTime, Nothing} = nothing,
		name::String,
		categories::Array{Union{Mongoc.BSONObjectId, Category}, 1},
		release::Dates.Date,
		kwargs...
	)
		new(_id, createdAt, updatedAt, name, categories, release)
	end
end

JSON2.@format Movie "keywordargs" begin
	_id => (;name=:_id, omitempty=true)
	createdAt => (;name=:createdAt, omitempty=true)
	updatedAt => (;name=:updatedAt, omitempty=true)
	name => (;name=:name)
	categories => (;name=:categories)
	release => (;name=:release)
end
