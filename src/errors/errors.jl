module errors

import Mongoc

@enum ErrorType begin
	ENTRY_NOT_FOUND = 1
	VALIDATION_ERROR = 2
	ENTRY_EXISTS = 3
	ENTRY_DELETED = 4
	AUTHORIZATION_ERROR = 5
	TOKEN_EXPIRED = 6
	AUTHENTICATION_ERROR = 7
	TOKEN_INVALID = 8
	PERMISSION_ERROR = 9
	FATAL_ERROR = 10
	NOT_IMPLEMENTED_ERROR = 11
	UNSUPPORTED_MEDIA = 12
end

abstract type APIException <: Exception
end

struct NotFoundError <: APIException
	context::String
	code::Int
	type::ErrorType
	NotFoundError(context::String = "") = new("""entry not found$(strip(context) == "" ? "" : ": $context")""", 404, ENTRY_NOT_FOUND)
end
struct ValidationError <: APIException
	context::String
	code::Int
	type::ErrorType
	ValidationError(context::String = "") = new("""invalid request parameter$(strip(context) == "" ? "" : ": $context")""", 400, VALIDATION_ERROR)
end
struct EntryExistsError <: APIException
	context::String
	code::Int
	type::ErrorType
	EntryExistsError(context::String = "") = new("""entry already exists$(strip(context) == "" ? "" : ": $context")""", 409, ENTRY_EXISTS)
end
struct EntryDeletedError <: APIException
	context::String
	code::Int
	type::ErrorType
	EntryDeletedError(context::String = "") = new("""entry has been deleted or deactivated$(strip(context) == "" ? "" : ": $context")""", 404, ENTRY_DELETED)
end
struct AuthorizationError <: APIException
	context::String
	code::Int
	type::ErrorType
	AuthorizationError(context::String = "") = new("""you are not authorized to view this resource$(strip(context) == "" ? "" : ": $context")""", 401, AUTHORIZATION_ERROR)
end
struct UnsupportedMediaError <: APIException
	context::String
	code::Int
	type::ErrorType
	UnsupportedMediaError(context::String = "") = new("""invalid media/file type$(strip(context) == "" ? "" : ": $context")""", 415, UNSUPPORTED_MEDIA)
end
struct ExpiredTokenError <: APIException
	context::String
	code::Int
	type::ErrorType
	ExpiredTokenError(context::String = "") = new("""expired token$(strip(context) == "" ? "" : ": $context")""", 401, TOKEN_EXPIRED)
end
struct InvalidTokenError <: APIException
	context::String
	code::Int
	type::ErrorType
	InvalidTokenError(context::String = "") = new("""invalid token$(strip(context) == "" ? "" : ": $context")""", 401, TOKEN_INVALID)
end
struct AuthenticationError <: APIException
	context::String
	code::Int
	type::ErrorType
	AuthenticationError(context::String = "") = new("""user could not be authenticated$(strip(context) == "" ? "" : ": $context")""", 401, AUTHENTICATION_ERROR)
end
struct PermissionError <: APIException
	context::String
	code::Int
	type::ErrorType
	PermissionError(context::String = "") = new("""you do not have permission to perform this action$(strip(context) == "" ? "" : ": $context")""", 403, PERMISSION_ERROR)
end
struct FatalError <: APIException
	context::String
	code::Int
	type::ErrorType
	FatalError(context::String = "") = new("""an error has occured on our end$(strip(context) == "" ? "" : ": $context")""", 500, FATAL_ERROR)
end
struct NotImplementedError <: APIException
	context::String
	code::Int
	type::ErrorType
	NotImplementedError(context::String = "") = new("""handler or method has not been implemented$(strip(context) == "" ? "" : ": $context")""", 501, NOT_IMPLEMENTED_ERROR)
end

Handler(err::T) where {T<:APIException} = err.code, err.context, err.type
Handler(err::Exception) = Handler(wrap(err))

wrap(err::T) where {T<:APIException} = err
wrap(err::Mongoc.BSONError) = EntryExistsError(string(err.message))
wrap(err::TypeError) = ValidationError(string(err.context))
wrap(::Union{MethodError, ArgumentError, EOFError}) = ValidationError()
wrap(err::ErrorException) = FatalError(string(err.msg))
wrap(::Exception) = FatalError()

end