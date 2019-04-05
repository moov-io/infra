## moov/fsftp

**NOTE**: This Docker is **not** designed for production use. Please use a production grade FTP server!

`moov/fsftp` is a Docker image for running an FTP server from with a filesystem backed. We bundle this in an image because the same test library is used in some of our applications.

```
$ docker run moov/fsftp:v0.1.0 -help
Usage of /bin/fsftp:
  -host string
    	Port (default "localhost")
  -pass string
    	Password for login (default "123456")
  -port int
    	Port (default 2121)
  -root string
    	Root directory to serve
  -user string
    	Username for login (default "admin")
```
