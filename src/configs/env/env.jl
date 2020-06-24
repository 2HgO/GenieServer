module env
	struct var
		app_env::String
		app_port::Int
		db_url::String
		db_name::String
		jwt_secret::String
		run_unsafe::Bool
		function var()
			app_env = haskey(ENV, "APP_ENV") ? ENV["APP_ENV"] : "local"
			app_port = haskey(ENV, "APP_PORT") ? parse(Int, ENV["APP_PORT"]) : 55099
			db_url = haskey(ENV, "DB_URL") ? ENV["DB_URL"] : "mongodb://localhost:27017"
			db_name = haskey(ENV, "DB_NAME") ? ENV["DB_NAME"] : "genie_server"
			jwt_secret = haskey(ENV, "JWT_SECRET") ? ENV["JWT_SECRET"] : "secretkey"
			run_unsafe = haskey(ENV, "RUN_UNSAFE") ? (ENV["RUN_UNSAFE"] == "true") : true
			new(app_env, app_port, db_url, db_name, jwt_secret, run_unsafe)
		end
	end

const envs = var()

end