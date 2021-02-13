## OSS Fuzzers Setup

Fuzzing is a technique for sending arbitrary input into functions to see what happens. Typically this is done to weed out crashers/panics from software, or to detect bugs. In some cases all possible inputs are ran into the program (i.e. if a function accepts 16-bit integers it's trivial to try them all).

We run fuzzers with [dvyukov/go-fuzz](https://github.com/dvyukov/go-fuzz) inside Docker containers so they can be deployed like any other long running service.

### Context

Each of our OSS projects has fuzzers that try and cause panics inside of the main `Read(..)` functions of the libraries. These functions consume arbitrary input and must not have vulnerabilities as our users depend on them to be very well hardened code paths.

Each project has a Go test function which attempts to read a directory of files that have caused crashes before fixing underlying issues. These are kept around as regression tests to ensure hardened parsers going forward.

### Data Collection and Analysis

Crasher files are collected inside a `crashers/` directory from where the fuzz binary runs from. Files with the input that caused the crash are written alongside the stacktrace.

#### Download Crashers

The first step for our fuzzers is to collect the "crashers" files that are produced. Those are typically created as a result of timeouts when evaluating functions. Our fuzz containers have CPU limits so they often are throttled and I believe that's the cause of timeouts.

```
$ ./cmd/cpfuzz/1-download.sh
found 5 fuzz containers
downloading ach fuzz data from achfuzz-686d549866-xrlgq
downloading 3 files from achfuzz-686d549866-xrlgq
...
downloading imagecashletter fuzz data from imagecashletterfuzz-65767469f8-lv6rr
downloading 2 files from imagecashletterfuzz-65767469f8-lv6rr
...
downloading iso8583 fuzz data from iso8583fuzz-7c567d8855-z76l5
downloading 3 files from iso8583fuzz-7c567d8855-z76l5
...
downloading metro2 fuzz data from metro2fuzz-7dcd79bfc7-sktz4
downloading 4 files from metro2fuzz-7dcd79bfc7-sktz4
...
downloading wire fuzz data from wirefuzz-656c5d4d6b-2mpkh
downloading 1 files from wirefuzz-656c5d4d6b-2mpkh
...
Saved files in fuzz-2021-02-12
```

This warning is outputted a lot when downloading the files. It's harmless.
```
tar: Removing leading `/' from member names
```

#### Copy Crashers to Projects

Each project (e.g. ACH, ICL, Wire) have a Go test function that attempts to parse these crashing files.

```
$ ./cmd/cpfuzz/2-copy-crashers-to-projects.sh
Using fuzz findings from fuzz-2021-02-12
```

A folder named `fuzz-YYYY-MM-DD` should be created in the root directory of this repository.

#### Prepare Packages

Each project's crasher files can be packaged into `.tar` files for easier distribution to teams.

```
$ ./cmd/cpfuzz/3-package-crashers.sh
Using fuzz findings from fuzz-2021-02-12
```

There will be `*.tar` files (e.g. `ach.tar`) created under the latest `fuzz-YYYY-MM-DD` directory.

#### Roll Fuzz Pods

After we've downloaded the crasher files deleting the existing pods so new instances are created helps to keep those directories clean. We should look at maintaining the additional corpus files across restarts.

```
$ ./cmd/cpfuzz/5-roll-fuzz-pods.sh
persistentvolumeclaim "achfuzz-data" deleted
deployment.apps "achfuzz" deleted
persistentvolumeclaim/achfuzz-data created
deployment.apps/achfuzz created
persistentvolumeclaim "imagecashletterfuzz-data" deleted
deployment.apps "imagecashletterfuzz" deleted
persistentvolumeclaim/imagecashletterfuzz-data created
deployment.apps/imagecashletterfuzz created
persistentvolumeclaim "wirefuzz-data" deleted
deployment.apps "wirefuzz" deleted
persistentvolumeclaim/wirefuzz-data created
deployment.apps/wirefuzz created
persistentvolumeclaim "metro2fuzz-data" deleted
deployment.apps "metro2fuzz" deleted
persistentvolumeclaim/metro2fuzz-data created
deployment.apps/metro2fuzz created
persistentvolumeclaim "iso8583fuzz-data" deleted
deployment.apps "iso8583fuzz" deleted
persistentvolumeclaim/iso8583fuzz-data created
deployment.apps/iso8583fuzz created
```
