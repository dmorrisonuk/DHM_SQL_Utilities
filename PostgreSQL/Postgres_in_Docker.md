# Postgres in Docker

> [!WARNING]  
> This is horrendously insecure and for demo purposes only! 
> 
<br>

# Versions Available




<br>


## Docker_Compose Script

This script will: 
1. Create a network called postgres_net
2. Create a container for Postgres (latest version) on port 5432
3. Create a container for pgadmin on external port 5050
4. Create volumes for both Postgres and pgAdmin to enable persistence. 

<br>

Script file:  
[docker-compose](docker-compose.yml)

<br> 

To initiate the containers, navigate to the folder containing the docker-compose file on your local machine, run a terminal (in admin mode) and use the `docker compose up` command.

<br>

## Using pgAdmin

Using pgAdmin allows you to inspect a Postgres DB running in docker.

### Manual Connection

-	Open PG admin by connecting to [localhost:5050](locahost:5050)
-	Select Add New Server
   - Provide a Server Name 
   - Add the Host Name as `postgres`
   - Add the Port as `5432`
   - Add the Username as `pguser`


<br>
[Setting up PostgreSQL and pgAdmin 4 with Docker](https://medium.com/@marvinjungre/get-postgresql-and-pgadmin-4-up-and-running-with-docker-4a8d81048aea)
<br> 

<br> 
The following will provide the IP address of the container to use that instead: 

``` 
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' [container_name]
```
<br>




### Automating Server Configuration

Adding ```servers.json``` file will allow most server configuration to be done automatically in pgAdmin client - the user will only need to specify the <i>Postgres</i> user password. 

__Parameter Description:__


"Servers": This is the root object that contains all the server configurations.

"1": This is the unique identifier for the server configuration. You can add multiple servers by using different identifiers (e.g., "2", "3").

"Name": The name of the server as it will appear in pgAdmin.

"Group": The group under which the server will be listed in pgAdmin. This helps organize multiple servers.

"Port": The port on which the PostgreSQL server is running. The default port for PostgreSQL is 5432.

"Username": The username to use when connecting to the PostgreSQL server.

"Host": The hostname or IP address of the PostgreSQL server. In this case, it's set to "db", which refers to the PostgreSQL service defined in the docker-compose.yml.

"SSLMode": The SSL mode to use for the connection. "prefer" means that SSL will be used if available, but it's not required.

"MaintenanceDB": The maintenance database to connect to, typically "postgres".


