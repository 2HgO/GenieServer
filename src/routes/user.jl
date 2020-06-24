const userRoutes = [
	Endpoint(path="/:userID", method=GET, handlerFuncs=(handlers.getUser,), name=:get_user),
	Endpoint(path="", method=GET, handlerFuncs=(handlers.getUsers,), name=:get_users),
	Endpoint(path="", method=DELETE, handlerFuncs=(handlers.deleteUser,), name=:delete_user),
	Endpoint(path="", method=PATCH, handlerFuncs=(handlers.updateUser,), name=:update_user),
	Endpoint(path="/search", method=GET, handlerFuncs=(handlers.searchUsers,), name=:search_users)
]