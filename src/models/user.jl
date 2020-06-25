struct Sensitive 
	val::String
end

Base.convert(::Type{String}, s::Sensitive) = s.val
Base.string(s::Sensitive) = convert(String, s)
Base.convert(::Type{Sensitive}, str::String) = Sensitive(str)
Base.:(==)(st::String, se::Sensitive) = st == se.val
Base.:(==)(se::Sensitive, st::String) = st == se.val

mutable struct User <: Model
	_id::Union{Mongoc.BSONObjectId, Nothing}
	createdAt::Union{Dates.DateTime, Nothing}
	updatedAt::Union{Dates.DateTime, Nothing}
	firstName::String
	lastName::String
	email::String
	password::Sensitive
	dob::Union{Dates.Date, Nothing}
	role::Role
	likes::Array{Union{Mongoc.BSONObjectId, Category}, 1}
	
	function User(;
		_id::Union{Mongoc.BSONObjectId, Nothing} = nothing,
		createdAt::Union{Dates.DateTime, Nothing} = nothing,
		updatedAt::Union{Dates.DateTime, Nothing} = nothing,
		firstName::String,
		lastName::String,
		email::String,
		password::Sensitive = Sensitive(""),
		dob::Union{Nothing, Dates.Date} = nothing,
		role::Role,
		likes::Array{Union{Mongoc.BSONObjectId, Category}, 1} = Union{Mongoc.BSONObjectId, Category}[],
		kwargs...
	)
		!utils.is_valid_email(email) && throw(errors.ValidationError("Invalid email"))
		# TODO: hash user password
		new(_id, createdAt, updatedAt, firstName, lastName, lowercase(email), password, dob, role, likes)
	end
end

JSON2.@format User "keywordargs" begin
	_id => (;name=:_id, omitempty=true)
	createdAt => (;name=:createdAt, omitempty=true)
	updatedAt => (;name=:updatedAt, omitempty=true)
	firstName => (;name=:firstName)
	lastName => (;name=:lastName)
	email => (;name=:email)
	password => (;name=:password, omitempty=true)
	dob => (;name=:dob, omitempty=true)
	role => (;name=:role, default=USER)
	likes => (;name=:likes)
end

JSON2.read(io::IO, ::Type{Sensitive}; kwargs...) = begin
	s = JSON2.read(io, String; kwargs...)
	return Sensitive(s)
end

JSON2.write(io::IO, id::Sensitive; db::Bool=true, redact::Bool=false, kwargs...) = begin
	if redact
		JSON2.write(io, nothing, kwargs...)
	else
		JSON2.write(io, string(id), kwargs...)
	end
	return
end