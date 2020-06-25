import JSON2
import Mongoc: aggregate, BSON, BSONObjectId, delete_one, find_one, update_one

import errors
import models
import db

include("user.jl")
include("movie.jl")
include("watchlist.jl")
include("category.jl")