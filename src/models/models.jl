module models

import Dates
import JSON2
import Mongoc

import utils
import errors

abstract type Model end

JSON2.read(io::IO, ::Type{Mongoc.BSONObjectId}; db=false, kwargs...) = begin
	s::String = ""
	if db
		pre = JSON2.read(io, Dict; kwargs...)
		s = pre["\$oid"]
	else
		s = JSON2.read(io, String; kwargs...)
	end
	id, ok = utils.safe_bson_id(s)
	!ok && throw(errors.ValidationError("Invalid ID"))
	return id
end

JSON2.write(io::IO, id::Mongoc.BSONObjectId; db::Bool=false, redact::Bool=false, kwargs...) = begin
	if db
		JSON2.write(io, Dict("\$oid" => string(id)), kwargs...)
	else
		JSON2.write(io, string(id), kwargs...)
	end
	return
end

JSON2.read(io::IO, ::Type{Union{Mongoc.BSONObjectId, model}}; aggregate = false, kwargs...) where {model <: Model} = begin
	if aggregate
		return JSON2.read(io, model, kwargs...)
	else
		return JSON2.read(io, Mongoc.BSONObjectId, kwargs...)
	end
end

JSON2.write(io::IO, any::Type{model}; db::Bool, redact::Bool, kwargs...) where {model<:Model} = JSON2.write(io::IO, any::Any; kwargs...)

function Base.push!(col::Mongoc.AbstractCollection, new_model::T) where {T<:Model}
	new_model.createdAt = Dates.now()
	new_model.updatedAt = Dates.now()
	res = push!(col, Mongoc.BSON(JSON2.write(new_model)))
	new_model._id = res.inserted_oid
end

function Mongoc.aggregate(col::Mongoc.Collection, pipeline::Mongoc.BSON, ::Type{model}; kwargs...) where {model<:Model}
	aggregation = Mongoc.aggregate(col, pipeline, kwargs...)
	return [JSON2.read(Mongoc.as_json(doc), model, db=true, aggregate=true) for doc in collect(aggregation)]
end

function Mongoc.delete_one(col::Mongoc.Collection, filter::Mongoc.BSON, ::Type{model}; kwargs...) where {model<:Model}
	query = Mongoc.find_one(col, filter, kwargs...)
	if query === nothing
		return query
	end
	res = JSON2.read(Mongoc.as_json(query), model, db=true)
	@async Mongoc.delete_one(col, filter, kwargs...)
	return res
end

include("category.jl")
include("movie.jl")
include("role.jl")
include("user.jl")
include("watchlist.jl")
export Category, Movie, Role, User, Watchlist
end