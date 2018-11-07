# Docker GoCD agent 18.10.0

* Updated to use GoCD version 18.10.0
* Removed alpine 3.5 agent image
* Removed ubuntu 12.04 agent image
* Introduced fedora 28 and 29 based docker agent images

# Docker GoCD agent 18.9.0

* Updated to use GoCD version 18.9.0

# Docker GoCD agent 18.8.0

* Updated to use GoCD version 18.8.0
* Introduced an alpine 3.8 based image
* Introduced an Ubuntu 18.04 based image

# Docker GoCD agent 18.7.0

* Updated to use GoCD version 18.7.0

# Docker GoCD agent 18.6.0

* Updated to use GoCD version 18.6.0

# Docker GoCD agent 18.5.0

* Updated to use GoCD version 18.5.0

# Docker GoCD agent 18.4.0

* Updated to use GoCD version 18.4.0

# Docker GoCD agent 18.3.0

* [b8b8672](https://github.com/gocd/docker-gocd-agent/commit/b8b8672) - Add GoCD Debian 9 Agent image.

# Docker GoCD agent 18.2.0

* [76b9abb](https://github.com/gocd/docker-gocd-agent/commit/76b9abb656be905be3837acf7890e8b891370476) - Add GoCD Docker In Docker Agent based on the official docker:dind image

# Docker GoCD agent 18.1.0

* [802c7b0](https://github.com/gocd/docker-gocd-agent/commit/802c7b04db0d6badc7608a6e7136bd6c71aeb0d7) - Add docker gocd agent alpine 3.7.

# Docker GoCD agent 17.12.0

* [#46](https://github.com/gocd/docker-gocd-server/issues/46) - add support for custom entry-point scripts on startup. Any executables volume mounted in `/docker-entrypoint.d` will be executed before starting the GoCD server. This will allow users to perform initialization when running the container, or building images that derive from the official GoCD docker agent images.

# Docker GoCD agent 17.11.0

* [63e0ee9](https://github.com/gocd/docker-gocd-agent/commit/63e0ee9e61d700bac614ea58340d3fa730f29a42) - Move to using logback for writing logs to `STDOUT`

# Docker GoCD agent 17.10.0

* [be41207](https://github.com/gocd/docker-gocd-agent/commit/be412073742ea08d14d3b655e0aad01e6ec6a8f2) Allow users to specify `uid` and `gid` as build args while building a docker image.
* [e1f4788](https://github.com/gocd/docker-gocd-agent/commit/e1f47886945e88b4cee07103935311833fb16087) Remove the volume instruction for godata directory. Fix for https://github.com/gocd/docker-gocd-server/issues/25

# Docker GoCD agent 17.9.0

* log agent output and logs to `STDOUT` in addition to writing logs to log files, so you can now watch all agent logs using `docker logs`.

# Docker GoCD agent 17.8.0

* [dc49b6d](https://github.com/gocd/docker-gocd-agent/commit/dc49b6df3856ebf91ae59562e42968ecca942b93) Create slimmer agent images by deleting the downloaded zip after extraction.

# Docker GoCD agent 17.7.0

No changes.

# Docker GoCD agent 17.6.0

No changes.

# Docker GoCD agent 17.5.0

No changes.

# Docker GoCD agent 17.4.0

## Bug Fixes

* [27b8772](https://github.com/gocd/docker-gocd-agent/commit/27b8772) Remove `/home/go` from the volume instruction. This makes the `/home/go` directory writable by `go` user.
* [44b592f](https://github.com/gocd/docker-gocd-agent/commit/44b592f) Create home directory `/home/go` for docker agent images based on debian.
