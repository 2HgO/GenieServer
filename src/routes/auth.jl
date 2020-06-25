const authRoutes = [
	Endpoint(path="/login/?", method=POST, handlerFuncs=(handlers.login,), name=:login),
	Endpoint(path="/forgot-password/?", method=POST, handlerFuncs=(handlers.forgotPassword,), name=:forgot_password),
	Endpoint(path="/reset-password/?", method=POST, handlerFuncs=(handlers.resetPassword,), name=:reset_password),
	Endpoint(path="/sign-up/?", method=PUT, handlerFuncs=(handlers.createUser,), name=:sign_up),
]