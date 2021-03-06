import env.var
import utils
import errors
import models
import controllers
import Dates: DateTime, now, Day
import JSON2
import JSONWebTokens: HS256, encode, decode
import Genie.Requests: rawpayload, jsonpayload, getpayload, payload, request
import HTTP: header

function safe_handler(func::Function, context::Dict{String,Any})
	return (() ->
		try
			func(context)
		catch e
			code, message, errorType = errors.wrap(e) |> errors.Handler
			utils.error_response(context, code, message, errorType)
		end
	)
end

function unsafe_handler(func::Function, context::Dict{String,Any})
	return (() -> func(context))
end

function admin_route(context::Dict{String, Any})
	!haskey(context, "user") && throw(errors.PermissionError("Login to continue"))
	(Int(context["user"].role) === 1) && throw(errors.PermissionError("only admins can perform this action"))
end

include("auth.jl")
include("user.jl")
include("middlewares.jl")
include("watchlist.jl")
include("category.jl")
include("movie.jl")