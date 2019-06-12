## moov/fsftp

**NOTE**: This Docker is **not** designed for production use. Please use a production grade FTP server!

`moov/fsftp` is a Docker image for running an FTP server from with a filesystem backed. We bundle this in an image because the same test library is used in some of our applications. It is based on [goftp/server](https://github.com/goftp/server/tree/master/exampleftpd)'s example FTP server.

```
$ docker run moov/fsftp:v0.2.0 -help
Usage of /bin/fsftp:
  -host string
    	TCP address to listen on (default "localhost")
  -pass string
    	Password for login (default "123456")
  -passive-ports string
    	Passive TCP port range to listen on (example: 30000-30009)
  -port int
    	TCP port to listen on (default 2121)
  -root string
    	Directory to serve files
  -user string
    	Username for login (default "admin")
```
