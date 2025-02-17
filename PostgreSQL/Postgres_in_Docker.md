# Postgres in Docker


<br>

# Versions Available




<br>


## Docker_Compose Script

This script will: 
1. Create a network called postgres_net
2. Create a container for Postgres (latest version) on port 5432
3. Create a container for pgadmin on port 5050
4. Create volumes for both Postgres and pgAdmin to enable persistence. 

<br>

Script file:  
[docker-compose](docker-compose.yml)

<br> 

To initiate the containers, navigate to the folder containing the docker-compose file on your local machine, run a terminal (in admin mode) and use the `docker compose up` command.

<br>

## Using pgAdmin

Using pgAdmin allows you to inspect a Postgres DB running in docker.

### Connection

-	Open PG admin by connecting to [localhost:5050](locahost:5050)
-	Select Add New Server
   - Provide a Server Name 
   - Add the Host Name as `postgres`
   - Add the Port as `5432`
   - Add the Username as `pguser`


<br>



