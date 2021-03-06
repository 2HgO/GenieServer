import errors.ErrorType

import Mongoc.BSONObjectId
import Printf.@printf
import HTTP.Response
import Dates


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

const µs = Dates.Microsecond(1)
const ms = Dates.Millisecond(1)
const s = Dates.Second(1)
const m = Dates.Minute(1)
const h = Dates.Hour(1)
const d = Dates.Day(1)

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

function get_duration(t::UInt)
	t_ns = Dates.Nanosecond(t)
	if t_ns > d
		return "$(round(t_ns, Dates.Day))"
	elseif t_ns > h
		return "$(round(t_ns, Dates.Hour).value)h"
	elseif t_ns > m
		return "$(round(t_ns, Dates.Minute).value)m"
	elseif t_ns > s
		return "$(round(t_ns, Dates.Second).value)s"
	elseif t_ns > ms
		return "$(round(t_ns, Dates.Millisecond).value)ms"
	else
		return "$(round(Dates.value(t_ns) * 1e-3, digits=3))µs"
	end
end


function generate_log(context::Dict{String,Any}, status)
	method = context["method"]
	path = context["path"]
	name = context["name"]
	stamp = context["stamp"]
	client = context["client"]
	duration = get_duration(time_ns() - stamp)
	statuscol = get_status_color(status)
	methodcol = get_method_color(method)

	name, Dates.format(Dates.now(), "Y/mm/dd - HH:MM:SS"), statuscol, status, reset, duration, client, methodcol, method, reset, path
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
	@printf "[GENIE-Error] :%25s => %s |%s %3d %s| %9s | %15s |%s %-7s %s %s\n" generate_log(context, status)...
	Response(status, context["headers"], body ="""{"success": false, "message": "$message", "error": "$error_type"}""")
end

function ok_response(context::Dict{String,Any}, status::Int, data::Union{String, Nothing}=nothing; message::String="", count::Union{UInt, Nothing}=nothing, token::Union{String, Nothing}=nothing)
	@printf "[GENIE]       :%25s => %s |%s %3d %s| %9s | %15s |%s %-7s %s %s\n" generate_log(context, status)...
	body = string(
		"{",
			"\"success\":true",
			data === nothing ? "" : ",\"data\": $data ",
			message === nothing ? "" : ",\"message\": \"$message\"",
			token === nothing ? "" : ",\"token\": \"$token\"",
			count === nothing ? "" : ",\"count\": $count",
		"}"
	)
	Response(status, context["headers"], body = body)
end