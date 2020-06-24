# Genie Server

Sample web server built using [Genie](https://github.com/GenieFramework/Genie.jl) (a framework for building web applications in [Julia](https://julialang.org/)

## Getting Started

### Prerequisites
---
* Docker (v18.03+)

### Start up
---
To build and run this project locally, run the following commands at the root directory of the project
```bash
docker-compose up --build
```
This will build the docker image, start up a [MongoDB](https://www.mongodb.com) container for the project and then start the project at port `55099` => [Genie Server](http://localhost:55099)

## Built With
---
* [Julia](https://julialang.org/) - Language used
* [Genie](https://github.com/GenieFramework/Genie.jl) - Web Framework used
* [MongoDB](https://www.mongodb.com) - Database used
  
## Documentation
---
Documentation for the Project can be found at [genie-server-doc](https://github.com/2HgO/GenieServer/blob/master/genie_server.raml)

## NOTE
---
This exact sample project has been implemented in [Go](https://golang.org) using the [Gin](https://github.com/gin-gonic/gin) web framework. Check it out over at [Gin-Server](https://github.com/2HgO/gin-server)