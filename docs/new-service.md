## Creating a new Moov HTTP service

1. Create a new repository on the [moov-io Github Organization](https://github.com/moov-io).
   - The repository should have a basic ["hello world" approach](https://github.com/moov-io/watchman/blob/v0.0.0/cmd/server/main.go) to get deploying right away.
1. To deploy a service needs a Docker image, build commands, and a binary to run. Since all of our applications are in Go we include a `Dockerfile` in each repository.
   1. [non cgo example](https://github.com/moov-io/ach/blob/master/Dockerfile)
   1. [cgo example](https://github.com/moov-io/auth/blob/master/Dockerfile) (needed for SQLite integration - via libc requirement)
1. In order for your applications metrics to be accumulated in [Grafana](https://infra.moov.io/grafana) it will need an admin servlet. This is designed for admin commands (i.e. forced refresh) and to offer a Prometheus metrics endpoint.
   1. [admin server example](https://github.com/moov-io/base/tree/master/admin#moov-iobaseadmin)
1. Add your service to `http/bind` (Example: [OFAC](https://github.com/moov-io/base/pull/33))

Once the application is setup we will deploy (manually, as all deploys are) the application into Kubernetes. This involves [adding a symlink and the Kubernetes objects](https://github.com/moov-io/infra/commit/b282521a7fa3cf1ab2659b19e79ba8ed0e2aa2d8) followed by someone with access running `kubectl apply -f apps/NN-your-app.yml`.

As always, talk with Adam for any questions. This process will be automated further as demand grows.

### Secure Coding

Please read over the [Web Application Secure Coding Practices](https://github.com/OWASP/Go-SCP) for Go.

### Persistence

Right now our default database is [SQLite](https://sqlite.org/index.html). We chose this because it's SQL-like and fairly dependency free. "SQL-like" means we should be able to translate the SQL queries over to another database such as Postgres, MySQL, or Oracle in the future. "fairly dependency free" refers to only requiring libc and a filesystem. The SQLite code is extremely well tested and performant for our initial usecases. This means backups consist of saving/encrypting two files and deployment requires C/CGO and a filesystem.

<p align="center">
  <a href="https://www.youtube.com/watch?v=RqubKSF3wig" target="_blank"><img src="https://img.youtube.com/vi/RqubKSF3wig/0.jpg" alt="SQLite and Go" /></a>
</p>
