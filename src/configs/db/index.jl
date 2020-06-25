import Mongoc
import env.var

mutable struct Collections
	Category::Union{Mongoc.Collection, Nothing}
	Movie::Union{Mongoc.Collection, Nothing}
	User::Union{Mongoc.Collection, Nothing}
	Watchlist::Union{Mongoc.Collection, Nothing}
end

const collections = Collections(nothing, nothing, nothing, nothing)

function __init__()
	client = Mongoc.Client(var().db_url)

	database = client[var().db_name]

	collections.Category = database["categories"]
	collections.Movie = database["movies"]
	collections.User = database["users"]
	collections.Watchlist = database["watchlists"]

	Mongoc.write_command(database, Mongoc.BSON(
		"createIndexes" => "users",
		"indexes" => [Mongoc.BSON("key" => Mongoc.BSON("email" => 1), "name" => "email_1", "unique" => true)]
	))
	Mongoc.write_command(database, Mongoc.BSON(
		"createIndexes" => "watchlists",
		"indexes" => [Mongoc.BSON("key" => Mongoc.BSON("user" => 1), "name" => "user_1", "unique" => true)]
	))
end