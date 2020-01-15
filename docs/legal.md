# Legal

## Update Copyright Headers

Each source file needs to have a header mentioning the associated Apache 2 license in it. Some projects include the Copyright year as part of this header.

To update this run the following command to move Copyright years ahead one.

```
$ set -x; find . -type f -name '*.go' | xargs -n1 sed -i '' "s/Copyright $(($(date +%Y)-1)) The Moov Authors/Copyright $(date +%Y) The Moov Authors/g"
```
