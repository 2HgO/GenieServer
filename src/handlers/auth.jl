mutable struct credentials
	email::String
	password::String
	credentials(;email::String="", password::String="") = begin
		!utils.is_valid_email(email) && throw(errors.ValidationError("Invalid email"))
		new(lowercase(email), password)
	end
end

JSON2.@format credentials "keywordargs" begin
	email => (;name=:email)
	password => (;name=:password)
end

function login(context::Dict{String,Any})
	jsonpayload() === nothing && throw(errors.ValidationError("Invalid request body"))
	creds::credentials = JSON2.read(rawpayload(), credentials)

	user = controllers.getUserByEmail(creds.email)
	!isequal(creds.password, user.password) && throw(errors.AuthenticationError("Invalid login credentials")) # TODO: implement hash compare function

	claims = Dict("user" => string(user._id), "exp" => string(now()+Day(1)))
	encoding = HS256(envs.jwt_secret) # TODO: change this to env variable
	token = encode(encoding, claims)

	utils.ok_response(context, 200, JSON2.write(user, redact=true), message="login successful", token=token)
end

function forgotPassword(context::Dict{String,Any})
	throw(errors.NotImplementedError())
end

function resetPassword(context::Dict{String,Any})
	throw(errors.NotImplementedError())
end
