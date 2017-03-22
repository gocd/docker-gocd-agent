# GoCD Agent Docker image

This repository is the parent repository for the following docker images

* [gocd/gocd-agent-centos-7](https://github.com/gocd/docker-gocd-agent-centos-7)
* [gocd/gocd-agent-centos-6](https://github.com/gocd/docker-gocd-agent-centos-6)
* [gocd/gocd-agent-ubuntu-16.04](https://github.com/gocd/docker-gocd-agent-ubuntu-16.04)
* [gocd/gocd-agent-ubuntu-14.04](https://github.com/gocd/docker-gocd-agent-ubuntu-14.04)
* [gocd/gocd-agent-ubuntu-12.04](https://github.com/gocd/docker-gocd-agent-ubuntu-12.04)
* [gocd/gocd-agent-debian-7](https://github.com/gocd/docker-gocd-agent-debian-7)
* [gocd/gocd-agent-debian-8](https://github.com/gocd/docker-gocd-agent-debian-8)

# Usage

- Build docker image for all images agent images by running —

```bash
export GOCD_VERSION=X.Y.Z
export GOCD_AGENT_DOWNLOAD_URL=https://download.gocd.io/binaries/X.Y.Z-PPPP/generic/go-agent-X.Y.Z-PPPP.zip
rake build_image [--trace]
```

- To build a specific image —

```bash
export GOCD_VERSION=X.Y.Z
export GOCD_AGENT_DOWNLOAD_URL=https://download.gocd.io/binaries/X.Y.Z-PPPP/generic/go-agent-X.Y.Z-PPPP.zip
rake -T build_image # list all targets
rake gocd-agent-ubuntu-12.04:build_image # build a specific image
```

- Publish or commit the Dockerfiles for all agents —

```bash
export GOCD_VERSION=X.Y.Z
export GOCD_AGENT_DOWNLOAD_URL=https://download.gocd.io/binaries/X.Y.Z-PPPP/generic/go-agent-X.Y.Z-PPPP.zip
rake publish [--trace]
```


# License

```plain
Copyright 2017 ThoughtWorks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
