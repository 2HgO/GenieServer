import routes
import env
import Logging: disable_logging, Info, Error
using Genie
import Genie.Router
import HTTP

# if env.envs.app_env !== "local"
disable_logging(Info)
disable_logging(Error)
# end

Genie.config.run_as_server = true
Genie.config.server_host = "0.0.0.0"
Genie.config.server_port = 55099
Genie.config.cors_allowed_origins = ["*"]
Genie.config.server_handle_static_files = false

routes.SetupRoutes()
if env.envs.app_env === "local"
	for (name, route) in  Router.named_routes()
		println("[GENIE-Local] $name => $(route.method)   $(route.path) --> $(route.action)")
	end
end

function force_compile()
  sleep(5)

	for (name, r) in Router.named_routes()
    HTTP.request(r.method, "http://localhost:55099" * r.path)
  end
end

@async force_compile()

try
	up(async=false)
catch ex
finally
	down()
end