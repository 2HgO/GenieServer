mutable struct Category <: Model
	_id::Union{Mongoc.BSONObjectId, Nothing}
	createdAt::Union{Dates.DateTime, Nothing}
	updatedAt::Union{Dates.DateTime, Nothing}
	name::String
	icon::String

	function Category(;name::String, icon::String, updatedAt::Union{Dates.DateTime, Nothing}=nothing, createdAt::Union{Dates.DateTime, Nothing}=nothing, _id::Union{Mongoc.BSONObjectId, Nothing}=nothing)
		new(_id, createdAt, updatedAt, name, icon)
	end
end

JSON2.@format Category "keywordargs" begin
	_id => (;name=:_id, omitempty=true)
	createdAt => (;name=:createdAt, omitempty=true)
	updatedAt => (;name=:updatedAt, omitempty=true)
	name => (;name=:name)
	icon => (;name=:icon, omitempty=true)
end
