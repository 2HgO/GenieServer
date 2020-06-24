module utils

import errors.ErrorType

import Mongoc.BSONObjectId
import Printf.@printf
import HTTP.Response
import Dates: format, now


const green   = "\033[97;42m"
const white   = "\033[90;47m"
const yellow  = "\033[90;43m"
const red     = "\033[97;41m"
const blue    = "\033[97;44m"
const magenta = "\033[97;45m"
const cyan    = "\033[97;46m"
const reset   = "\033[0m"

const GET = "GET"
const POST = "POST"
const PUT = "PUT"
const PATCH = "PATCH"
const DELETE = "DELETE"
const OPTIONS = "OPTIONS"
const HEAD = "HEAD"

function get_method_color(method)
	if (method == GET)
		return blue
	elseif (method == POST)
		return cyan
	elseif (method == PUT) 
		return yellow 
	elseif (method == PATCH) 
		return green
	elseif (method == OPTIONS) 
		return white
	elseif (method == DELETE) 
		return red 
	elseif (method == HEAD) 
		return magenta 
	else
		return reset
	end
end

function get_status_color(status)
	if (status < 300)
		return green
	elseif (status < 400)
		return white
	elseif (status < 500)
		return yellow
	else
		return red
	end
end

function generate_log(context::Dict{String,Any}, status)
	method = context["method"]
	path = context["path"]
	name = context["name"]
	stamp = context["stamp"]
	client = context["client"]
	duration = (now() - stamp).value
	statuscol = get_status_color(status)
	methodcol = get_method_color(method)

# FORMAT: [GIN] 2020/06/23 - 23:21:11 | 404 |     781.528µs |             ::1 | GET      /users/search

	name, format(stamp, "Y/m/d - H:M:S"), statuscol, status, reset, duration, client, methodcol, method, reset, path
end

function safe_bson_id(id::AbstractString) :: Tuple{Union{BSONObjectId, Nothing}, Bool}
	try
		valid_id = BSONObjectId(string(id))
		return valid_id, true
	catch e
		return nothing, false
	end
end

function is_valid_email(email::String) :: Bool
	# email regex copied from https://emailregex.com/
	return occursin(r"""(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])""", email)
end

function error_response(context::Dict{String,Any}, status::Int, message::String, error_type::ErrorType)
	@printf "[GENIE-Error] :%22s => %s |%s %3d %s| %7dms | %15s |%s %-7s %s %s\n" generate_log(context, status)...
	Response(status, context["headers"], body ="""{"success": false, "message": "$message", "error": "$error_type"}""")
end

function ok_response(context::Dict{String,Any}, status::Int, data::String; message::String="", count::Union{UInt, Nothing}=nothing, token::Union{String, Nothing}=nothing)
	@printf "[GENIE]       :%22s => %s |%s %3d %s| %7dms | %15s |%s %-7s %s %s\n" generate_log(context, status)...
	body = string(
		"{",
			"\"success\":true,",
			"\"date\": $data ",
			message === nothing ? "" : ",\"message\": \"$message\"",
			token === nothing ? "" : ",\"token\": \"$token\"",
			count === nothing ? "" : ",\"count\": $count",
		"}"
	)
	Response(status, context["headers"], body = body)
end

end