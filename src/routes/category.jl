const categoryRoutes = [
	Endpoint(path="/:categoryID/?", method=GET, handlerFuncs=(handlers.getCategory,), name=:get_category),
	Endpoint(path="/?", method=GET, handlerFuncs=(handlers.getCategories,), name=:get_categories),
	Endpoint(path="/:categoryID/?", method=DELETE, handlerFuncs=(handlers.admin_route, handlers.deleteCategory,), name=:delete_category),
	Endpoint(path="/?", method=PUT, handlerFuncs=(handlers.admin_route, handlers.createCategory,), name=:create_category),
	Endpoint(path="/search/?", method=GET, handlerFuncs=(handlers.searchCategories,), name=:search_categories)
]