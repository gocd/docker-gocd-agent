# Docker GoCD agent 17.4.0

## Bug Fixes

* [27b8772](https://github.com/gocd/docker-gocd-agent/commit/27b8772) Remove `/home/go` from the volume instruction. This makes the `/home/go` directory writable by `go` user.
* [44b592f](https://github.com/gocd/docker-gocd-agent/commit/44b592f) Create home directory `/home/go` for docker agent images based on debian. 
