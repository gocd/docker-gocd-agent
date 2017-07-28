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
