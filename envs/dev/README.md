## Moov Local Development Environment

This setup is for testing Moov's stack and Kong locally. To use this you'll need Terraform and Docker Compose installed. The [Terraform Kong Provider](https://github.com/kevholditch/terraform-provider-kong) is used to setup resources. See the [Kong Admin API docs](https://docs.konghq.com/2.0.x/admin-api/) for further reference.

Then install the desired [plugin release](https://github.com/kevholditch/terraform-provider-kong/releases) following Terraform's [Third-party plugin docs](https://www.terraform.io/docs/configuration/providers.html#third-party-plugins).

### Running

```
# Start all containers and tail their logs
$ docker-compose up

# Setup Kong Services and Routes
$ terraform apply -auto-approve
```

## Getting Help

 channel | info
 ------- | -------
[GitHub Issue](https://github.com/moov-io) | If you are able to reproduce a problem please open a GitHub Issue under the specific project that caused the error.
[moov-io slack](https://slack.moov.io/) | Join our slack channel (`#infra`) to have an interactive discussion about the development of the project.
