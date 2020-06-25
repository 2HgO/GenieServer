const movieRoutes = [
	Endpoint(path="/:movieID/?", method=GET, handlerFuncs=(handlers.getMovie,), name=:get_movie),
	Endpoint(path="/category/:categoryID/?", method=GET, handlerFuncs=(handlers.getMoviesByCategory,), name=:get_movies_by_cat),
	Endpoint(path="/:movieID/?", method=DELETE, handlerFuncs=(handlers.admin_route, handlers.deleteMovie,), name=:delete_movie),
	Endpoint(path="/?", method=PUT, handlerFuncs=(handlers.admin_route, handlers.createMovie,), name=:create_movie),
	Endpoint(path="/?", method=GET, handlerFuncs=(handlers.getMovies,), name=:get_movies),
	Endpoint(path="/search/?", method=GET, handlerFuncs=(handlers.searchMovies,), name=:search_movies)
]