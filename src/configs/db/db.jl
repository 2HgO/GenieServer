module db

import Mongoc
import env.envs

mutable struct Collections
	Category::Union{Mongoc.Collection, Nothing}
	Movie::Union{Mongoc.Collection, Nothing}
	User::Union{Mongoc.Collection, Nothing}
	Watchlist::Union{Mongoc.Collection, Nothing}
end

const collections = Collections(nothing, nothing, nothing, nothing)

function __init__()
	client = Mongoc.Client(envs.db_url)

	database = client[envs.db_name]

	collections.Category = database["categories"]
	collections.Movie = database["movies"]
	collections.User = database["users"]
	collections.Watchlist = database["watchlists"]

	Mongoc.write_command(database, Mongoc.BSON(
	"createIndexes" => "users",
	"indexes" => [Mongoc.BSON("key" => Mongoc.BSON("email" => 1), "name" => "email_1", "unique" => true)]
	))
end

end
	