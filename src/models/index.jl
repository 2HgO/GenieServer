import Dates
import JSON2
import Mongoc

import utils
import errors

abstract type Model end

const datetime_format = Dates.DateFormat("yyyy-mm-dd\\THH:MM:SS.sZ")
const date_format = Dates.DateFormat("yyyy-mm-dd\\THH:MM:SSZ")


JSON2.read(io::IO, ::Type{Mongoc.BSONObjectId}; db::Bool=false, kwargs...) = begin
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

JSON2.read(io::IO, ::Type{Dates.DateTime}; db::Bool=false, kwargs...) = begin
	s::String = ""
	if db
		pre = JSON2.read(io, Dict; kwargs...)
		s = pre["\$date"]
	else
		s = JSON2.read(io, String; kwargs...)
	end
	datetime = Dates.DateTime(s, datetime_format)
	return datetime
end

JSON2.read(io::IO, ::Type{Dates.Date}; db::Bool=false, kwargs...) = begin
	s::String = ""
	if db
		pre = JSON2.read(io, Dict; kwargs...)
		s = pre["\$date"]
	else
		s = JSON2.read(io, String; kwargs...)
	end
	date = Dates.Date(Dates.DateTime(s, date_format))
	return date
end

JSON2.write(io::IO, datetime::Dates.DateTime; db::Bool=false, redact::Bool=false, kwargs...) = begin
	if db
		JSON2.write(io, Dict("\$date" => round(Int, Dates.datetime2unix(datetime) * 1000)), kwargs...)
	else
		JSON2.write(io, string(datetime), kwargs...)
	end
	return
end

JSON2.write(io::IO, date::Dates.Date; db::Bool=false, redact::Bool=false, kwargs...) = begin
	if db
		JSON2.write(io, Dict("\$date" => round(Int, Dates.datetime2unix(Dates.DateTime(date)) * 1000)), kwargs...)
	else
		JSON2.write(io, string(date), kwargs...)
	end
	return
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
		return JSON2.read(io, model; kwargs...)
	else
		return JSON2.read(io, Mongoc.BSONObjectId; kwargs...)
	end
end

JSON2.write(io::IO, any::Type{model}; db::Bool, redact::Bool, kwargs...) where {model<:Model} = JSON2.write(io::IO, any::Any; kwargs...)
function JSON2.read(io::IO, ::Type{model}; db::Bool=false, kwargs...) where {model<:Model}
	JSON2.read(io, any; kwargs...)
end

function Base.push!(col::Mongoc.AbstractCollection, new_model::T) where {T<:Model}
	new_model.createdAt = Dates.now()
	new_model.updatedAt = Dates.now()
	res = push!(col, Mongoc.BSON(JSON2.write(new_model, db=true)))
	new_model._id = res.inserted_oid
end

function Mongoc.aggregate(col::Mongoc.Collection, pipeline::Mongoc.BSON, ::Type{model}; kwargs...) where {model<:Model}
	aggregation = Mongoc.aggregate(col, pipeline, kwargs...)
	return [JSON2.read(Mongoc.as_json(doc), model, db=true, aggregate=true) for doc in collect(aggregation)]
end

function Mongoc.find_one(col::Mongoc.Collection, filter::Mongoc.BSON, ::Type{model}; kwargs...) where {model<:Model}
	res = Mongoc.find_one(col, filter, kwargs...)
	(res === nothing) && throw(errors.NotFoundError("""$(split(lowercase(string(model)), ".")[end]) does not exist"""))
	return JSON2.read(Mongoc.as_json(res), model, db=true)
end

function Mongoc.delete_one(col::Mongoc.Collection, filter::Mongoc.BSON, ::Type{model}; kwargs...) where {model<:Model}
	res = Mongoc.find_one(col, filter, model, kwargs...)
	@async Mongoc.delete_one(col, filter, kwargs...)
	return res
end

include("category.jl")
include("movie.jl")
include("role.jl")
include("user.jl")
include("watchlist.jl")