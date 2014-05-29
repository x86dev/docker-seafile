Docker image for Seafile
--------------------

This Dockerfile installs [Seafile](https://www.seafile.com) 3.x with HTTPS (TLS) enabled by default.

Idea and initial Dockerfile was based on https://github.com/alvistar/seafile-docker

## Features

The image contains/adds the following:
- Support for Seafile 3.x
- Nginx for TLS (HTTPS) support
- Self-signed certificates, generated automatically on first run
- Runit for keeping the services up and running

## Architecture

For running Seafile within Docker, three containers are needed, namely:
- **seafile**, which contains the actual Seafile instance running on the server
- **seafile-db**, the MySQL database container
- **seafile-data**, the data container

Having different containers is nice if you need/want to upgrade and/or backup
your installation.

## Quickstart

Create the MySQL database container by running: 
```bash
    docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=<password> -e MYSQL_DATABASE=seafile -e MYSQL_USER=seafile --name seafile-db orchardup/mysql
```
This will create the needed container, based on [orchardup/mysql](https://index.docker.io/u/orchardup/mysql/). This also assumes that you're
not yet running another database at port 3306 on your host. In case you do, e.g. use
```
-p 3307:3306
```
to expose the database' internal port 3306 to 3307 on your host.

As we need the IP of your database container later, look it up by doing a

```bash
docker inspect "seafile-db" | grep IPAddress | cut -d '"' -f 4
```

Now, create the actual Seafile volume (for storing the actual data), using:

```bash
    docker run -it --dns=127.0.0.1 --link seafile-db:db --name seafile-data -e SEAFILE_DOMAIN_NAME=<yourdomain.tld> x86dev/docker-seafile /sbin/my_init -- bootstrap
```

**Note:** The <yourdomain.tld> should either point to a IP or valid domain you want to run Seafile on. If you're running Docker on
your localhost you simply can specify _127.0.0.1_.

**Bonus:** If you want to specify a different port than _8080_, add the parameter
```
SEAFILE_DOMAIN_PORT=<yourport>
```
to the command line above. Don't forget to change the port at the final command later on though! 

The script which now runs will ask a few questions to correctly set up all the things for you, in particular:
```
"What is the name of the server?"
```
Hint: Enter the name (**not** a domain or IP!) of this Seafile installation.

```
"What is the ip or domain of the server?"
```
Hint: If you're running Docker on your local PC, enter **127.0.0.1** -- otherwise enter the IP or
domain of your server you're running Docker on.

```
"What is the host of mysql server?"
```
Hint: Enter the IP of your **seafile-db** container, e.g. 172.17.0.2. Remember the step from above?

**Important:** For all other questions just accept the defaults by pressing [ENTER]

Almost done! Now actually run Seafile using the database and the volume with:

```bash
    docker run -d -t --dns=127.0.0.1 -p 10001:10001 -p 8082:8082 -p 12001:12001 -p 8080:8080 --volumes-from seafile-data --link seafile-db:db --name seafile x86dev/docker-seafile
```

Seafile should now be running on your host at 

```
https://<yourhost>:8080
```

Congrats, you're now running Seafile using your self-signed certificate!
