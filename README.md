## Introduction

This project demonstates a proof-of-concept snapshot testing framework for
ensuring non-regression in Ansible inventories.

## The problem

As the amount and structure of groups and hosts grows in Ansible inventories,
any refactoring becomes harder and riskier, as updating one group may impact
a whole lot of sub-groups and hosts.

One may be interested automatically testing the values of the variables
associated to each host. However, manually defining them in a separate file
for each host, for comparison, is tedious, and defeats the whole point of
leveraging Ansible groups in the first place.

## Snapshot testing

In such scenarios, where we want to test results without having to actually
define them manually, one can leverage snapshot testing, as implemented by
frameworks such as [Jest](https://jestjs.io/docs/snapshot-testing) in
JavaScript or [Birdie](https://hexdocs.pm/birdie/) in Gleam.

Basically, upon the first time the test is executed, a snapshot of the
values under test is created, validated by the user, and typically saved
into a file, that is to be committed into your version control system.

Then, the next time that the test runs, the values under test are simply
compared against the corresponding snapshot. If the values match, then
the test passes, otherwise it fails. The user can choose to re-generate
the snapshot if the expected values changed.

## Proposed solution

### Creating the snapshots

The [sync.sh](sync.sh) script allows for creating a snapshot of the relevant
variables. It leverages the [snapshot.yml](snapshot.yml) playbook, that
defines the list of `snapshot_vars`, gathers their values for each provided
host, and dumps them into a file.

However, these variables may include sensitive information, such as credentials,
so they must not be committed directly into the version control system. Instead,
[Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/vault.html)
is used to encrypt the files using [a given password](vault_secret.sh). They
can then safely be committed, then decrypted using the same password.

First, install all the required dependencies:

```sh
./install.sh
```

Then, you can run the script for generating the snapshots for the given Ansible
limit. For each host, it will dump the relevant variables into a
`snapshots/expected/decrypted/<host>.yml` file (which is `.gitignore`d),
and then encrypt it into the `snapshots/expected/encrypted/<host>.yml` file.

```sh
./sync.sh all
```

### Testing the values against the snapshots

Similarly, the [test.sh](test.sh) script first dumps all relevant variables
for all hosts, into the un-encrypted `.gitignore`d `snapshots/actual/` folder.

The `snapshots/expected/encrypted/` folder is then decrypted into
`snapshots/expected/decrypted/`.

Finally, the actual and the expected folders contents are compared, and the
tests fail if there is any mismatch.

You can run these tests using:

```sh
./test.sh
```

## Further work

The naive folder comparison test uses
`diff -r snapshots/actual/ snapshots/expected/decrypted/`, which directly
writes mismatches to the standard output. However, once again, this may
include sensitive information, so you should not use it as-is as a part of
your CI/CD pipelines.

Additionally, for better performance, one may look into caching the results
of the tests of the hosts for which no variable nor parent group was altered.
