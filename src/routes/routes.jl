module routes
import Genie.Router: route, GET, POST, PUT, PATCH, DELETE
import Genie.Requests: matchedroute, request
import HTTP: header, hasheader
import handlers
import env.envs

import Dates

const wrappers = (handlers.safe_handler, handlers.unsafe_handler)

struct Endpoint
	path::String
	handlerFuncs::Tuple{Vararg{Function}}
	method::String
	name::Symbol
end
Endpoint(;path::String="", handlerFuncs::Tuple{Vararg{Function}}, method::String, name = Symbol("")) = Endpoint(path, handlerFuncs, method, name)

function load_routes(baseURL::String, endpoints::Array{Endpoint}; pre::Tuple{Vararg{Function}}=Tuple{Vararg{Function}}())
	for endpoint in endpoints
		name = ifelse(endpoint.name != Symbol(""), endpoint.name,Symbol(join(split(lowercase(endpoint.method)*"/"*endpoint.path, "/"), "_")))
		route(merge_handlers(endpoint.handlerFuncs, pre=pre, unsafe=envs.run_unsafe), baseURL*endpoint.path, method=endpoint.method, named=name)
	end
end

function merge_handlers(handlerFuncs::Tuple{Vararg{Function}}; pre::Tuple{Vararg{Function}}=Tuple{Vararg{Function}}(), unsafe=true)
	context = Dict{String, Any}("headers" => Vector{Pair{String, String}}())

	return wrappers[unsafe+1]((ctx::Dict{String, Any}) -> begin
		ctx["client"] = get_client_ip()
		ctx["method"] = matchedroute().method
		ctx["path"] = matchedroute().path
		ctx["name"] = matchedroute().name
		ctx["stamp"] = Dates.now()
		ctx["errors"] = Exception[]
		length(handlerFuncs) < 1 && throw(errors.NotImplementedError("no time"))
		for handlerFunc in pre
			handlerFunc(ctx)
		end
		for handlerFunc in handlerFuncs[1:end-1]
			handlerFunc(ctx)
		end
		return handlerFuncs[end](ctx)
	end
	, context)
end

get_client_ip() = begin
	client = strip(split(string(header(request(), "X-Forwarded-For", "")), ",")[1])
	if client != ""
		return client
	end
	client = strip(string(header(request(), "X-Real-Ip", "")))
	if client != ""
		return client
	end
	client = strip(string(header(request(), "X-Appengine-Remote-Addr", "")))
	return client
end


include("user.jl")
include("auth.jl")
include("movie.jl")
include("category.jl")
include("watchlist.jl")

function SetupRoutes()
	load_routes("/users", userRoutes, pre=(handlers.setHeaders!, handlers.setJSONHeader!, handlers.userValidation!))
	load_routes("/auth", authRoutes, pre=(handlers.setHeaders!, handlers.setJSONHeader!))
	load_routes("/movies", movieRoutes, pre=(handlers.setHeaders!, handlers.setJSONHeader!, handlers.userValidation!))
	load_routes("/categories", categoryRoutes, pre=(handlers.setHeaders!, handlers.setJSONHeader!, handlers.userValidation!))
	load_routes("/watchlists", watchlistRoutes, pre=(handlers.setHeaders!, handlers.setJSONHeader!, handlers.userValidation!))
end
end