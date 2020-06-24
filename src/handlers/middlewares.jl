function setHeaders!(context::Dict{String,Any})
	push!(context["headers"], ("Access-Control-Allow-Headers" => "Origin, X-Requested-With, Content-Type, Accept"))
	push!(context["headers"], ("Access-Control-Allow-Credentials" => "true"))
end

function setJSONHeader!(context::Dict{String,Any})
	push!(context["headers"], ("Content-Type" => "application/json"))
end

function userValidation!(context::Dict{String,Any})
	authorization = header(request(), "Authorization")
	length(authorization) < 7 && throw(errors.AuthenticationError("no auth token"))

	token = string(authorization[8:end])
	length(strip(token)) < 1 && throw(errors.InvalidTokenError("please login to continue"))

	encoding = HS256(envs.jwt_secret) # TODO: change this to env variable
	claims = decode(encoding, token)

	(!haskey(claims, "user") || !haskey(claims, "exp")) && throw(errors.InvalidTokenError())
	try
		DateTime(string(claims["exp"]))
	catch ex
		throw(errors.InvalidTokenError())
	end
	(now() > DateTime(string(claims["exp"]))) && throw(errors.ExpiredTokenError())

	id, ok = utils.safe_bson_id(string(claims["user"]))
	!ok && throw(errors.InvalidTokenError("invalid token payload"))

	context["user"] = controllers.getUser(id)
end

function handle404(::Dict{String, Any})
	throw(errors.NotFoundError("API endpoint not found"))
end