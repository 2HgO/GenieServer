const watchlistRoutes = [
	Endpoint(path="/user/:userID/?", method=GET, handlerFuncs=(handlers.getWatchlist,), name=:get_user_watchlist),
	Endpoint(path="/movie/:movieID/?", method=PUT, handlerFuncs=(handlers.addMovieToUserWatchlist,), name=:add_movie_to_watchlist),
	Endpoint(path="/movie/:movieID/?", method=DELETE, handlerFuncs=(handlers.removeMovieFromUserWatchlist,), name=:rem_movie_from_watchlist)
]