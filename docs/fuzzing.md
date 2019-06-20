## Fuzzing

Fuzzing is a technique for sending arbitrary input into functions to see what happens. Typically this is done to weed out crashes/panics from software, or to detect bugs. In some cases all possible inputs are ran into the program (i.e. if a function accepts 16-bit integers it's trivial to try them all).

Moov runs Docker containers of several applications which execute [go-fuzz](https://github.com/dvyukov/go-fuzz) inside of them. This is designed to automate fuzzing and ensure higher quality software. Right now analysis of fuzz results is manual.

For example, if we're running fuzzing for `ach` the `Deployment` would be called `achfuzz`. We also run these fuzz containers as a low `PriorityClass` called `fuzz-low-priority` which pushes fuzzing cpu time down if production requests need more cpu or memory.

After you [setup `kubectl`](kubernetes.md) and authentiate [with Google's Cloud](google-cloud.md) you can download the fuzz data. You'll need to run `cpfuzz.sh` located at `cmd/cpfuzz/cpfuzz.sh` from the root of the infra repository.

```
$ ./cmd/cpfuzz/cpfuzz.sh
downloading ach fuzz data from achfuzz-6b79569674-zbf67
downloading imagecashletter fuzz data from imagecashletterfuzz-76d76f654f-gmczz
downloading wire fuzz data from wirefuzz-665478856d-8gpnr
Saves files in fuzz-2019-06-20

# List any files we downloaded from the Kubernetes cluster
$ ls -lR fuzz-2019-06-20
total 0
drwxr-xr-x   2 adam  staff    64 Jun 20 13:13 ach
drwxr-xr-x  44 adam  staff  1408 Jun 20 13:15 imagecashletter
drwxr-xr-x   5 adam  staff   160 Jun 20 13:15 wire

fuzz-2019-06-20/ach:

fuzz-2019-06-20/imagecashletter:
total 336
-rw-r--r--  1 adam  staff    80 Jun 20 13:19 133c10731f259a744004b73de062f708f083a1ea
-rw-r--r--  1 adam  staff  1215 Jun 20 13:19 133c10731f259a744004b73de062f708f083a1ea.output
-rw-r--r--  1 adam  staff   102 Jun 20 13:19 133c10731f259a744004b73de062f708f083a1ea.quoted

fuzz-2019-06-20/wire:
total 24
-rw-r--r--  1 adam  staff     6 Jun 20 13:21 57ae8dc36e862a59c605060bb6fc2ff14d9b6fa6
-rw-r--r--  1 adam  staff  1015 Jun 20 13:21 57ae8dc36e862a59c605060bb6fc2ff14d9b6fa6.output
-rw-r--r--  1 adam  staff    10 Jun 20 13:21 57ae8dc36e862a59c605060bb6fc2ff14d9b6fa6.quoted
```

After downloading each `*.output` file contains the panic's trace and the other two files contain the input. Each crash should be verified correct with a test that passes in the respective project.
