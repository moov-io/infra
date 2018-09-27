## secrets

> "I know that's a secret, for it's whispered everywhere." -- William Congreve

We store secrets a couple of ways inside this repository. For kubernetes resources we're just [using StackExchange/blackbox](https://github.com/StackExchange/blackbox) to encrypt the files and for terraform state we're storing that inside google cloud storage.

### Install / Setup

You'll need a GPG key for blackbox, ideally a new one specific to moov. Add a passphrase and make it 4096bit.

```
$ git clone git@github.com:moov-io/infra
$ cd infra/

# Pull down submodules (i.e. blackbox)
$ git submodule init && git submodule update

# Create a passphrase protected 4096bit key
$ gpg --gen-key

# (Optional) Export key material (lastpass, offline storage)
$ gpg --export <key-id> > ${USER}-moov.pub
$ gpg --export-secret-key <key-id> > ${USER}-moov.pem
```

### Adding a new blackbox admin

The following steps can be used to add a new blackbox admin.

```
# Export a public key (so they can add you)
$ gpg --export <key-id> > $name.pub

$ gpg --list-keys
/home/adam/.gnupg/pubring.gpg
-----------------------------
pub   4096R/700D183B 2018-09-26
uid                  Adam Shannon (moov.io) <adam@moov.io>
sub   4096R/CBA93839 2018-09-26

$ ./blackbox/bin/blackbox_addadmin 700D183B
gpg: keyring `/home/adam/code/src/github.com/moov-io/secrets/keyrings/live/secring.gpg' created
gpg: keyring `/home/adam/code/src/github.com/moov-io/secrets/keyrings/live/pubring.gpg' created
gpg: /home/adam/code/src/github.com/moov-io/secrets/keyrings/live/trustdb.gpg: trustdb created
gpg: key 700D183B: public key "Adam Shannon (moov.io) <adam@moov.io>" imported
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)


NEXT STEP: You need to manually check these in:
      git commit -m'NEW ADMIN: 700D183B' keyrings/live/pubring.gpg keyrings/live/trustdb.gpg keyrings/live/blackbox-admins.txt

$ git commit -m'NEW ADMIN: 700D183B' keyrings/live/pubring.gpg keyrings/live/trustdb.gpg keyrings/live/blackbox-admins.txt

$ git push origin master
```

## TODO decrypt sanity with gpg-agent

// TODO(adam): ~/.gnupg/gpg-agent.conf magic setup
