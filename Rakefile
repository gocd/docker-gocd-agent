# Copyright 2017 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'erb'
require 'open-uri'
require 'json'

def get_var(name)
  if ENV[name].to_s.strip.empty?
    raise "environment #{name} not specified!"
  else
    ENV[name]
  end
end

gocd_version = get_var('GOCD_VERSION')
download_url = get_var('GOCD_AGENT_DOWNLOAD_URL')
gocd_full_version = get_var('GOCD_FULL_VERSION')
gocd_git_sha = get_var('GOCD_GIT_SHA')

ROOT_DIR = Dir.pwd

def tini_assets
  @tini_assets ||= JSON.parse(open('https://api.github.com/repos/krallin/tini/releases/latest').read)['assets']
end

def gosu_assets
  @gosu_assets ||= JSON.parse(open('https://api.github.com/repos/tianon/gosu/releases/latest').read)['assets']
end

def tini_url
  tini_assets.find { |asset| asset['browser_download_url'] =~ /tini-static-amd64$/ }['browser_download_url']
end

def gosu_url
  gosu_assets.find { |asset| asset['browser_download_url'] =~ /gosu-amd64$/ }['browser_download_url']
end

tini_and_gosu_add_file_meta = {
  '/usr/local/sbin/tini' => { url: tini_url, mode: '0755', owner: 'root', group: 'root' },
  '/usr/local/sbin/gosu' => { url: gosu_url, mode: '0755', owner: 'root', group: 'root' }
}

create_user_and_group_cmd = [
  'groupadd -g ${GID} go',
  'useradd -u ${UID} -g go -d /home/go -m go'
]

maybe_credentials = "#{ENV['GIT_USER']}:#{ENV['GIT_PASSWORD']}@" if ENV['GIT_USER'] && ENV['GIT_PASSWORD']

[
  {
    distro: 'alpine',
    version: '3.5',
    add_files: tini_and_gosu_add_file_meta,
    create_user_and_group: [
      'addgroup -g ${GID} go',
      'adduser -D -u ${UID} -s /bin/bash -G go go'
    ],
    before_install: [
      'apk --no-cache upgrade',
      'apk add --no-cache openjdk8-jre-base git mercurial subversion openssh-client bash curl'
    ]
  },
  {
      distro: 'alpine',
      version: '3.6',
      add_files: tini_and_gosu_add_file_meta,
      create_user_and_group: [
          'addgroup -g ${GID} go',
          'adduser -D -u ${UID} -s /bin/bash -G go go'
      ],
      before_install: [
          'apk --no-cache upgrade',
          'apk add --no-cache openjdk8-jre-base git mercurial subversion openssh-client bash curl'
      ]
  },
  {
    distro: 'alpine',
    version: '3.7',
    add_files: tini_and_gosu_add_file_meta,
    create_user_and_group: [
      'addgroup -g ${GID} go',
      'adduser -D -u ${UID} -s /bin/bash -G go go'
    ],
    before_install: [
      'apk --no-cache upgrade',
      'apk add --no-cache openjdk8-jre-base git mercurial subversion openssh-client bash curl'
    ]
  },
  {
    distro: 'docker',
    version: 'dind',
    add_files: tini_and_gosu_add_file_meta,
    repo_url: "https://#{maybe_credentials}github.com/#{ENV['REPO_OWNER'] || 'gocd'}/gocd-agent-docker-dind",
    create_user_and_group: [
      'addgroup -g ${GID} go',
      'adduser -D -u ${UID} -s /bin/bash -G go go',
      'addgroup go root'
    ],
    before_install: [
      'apk --no-cache upgrade',
      'apk add --no-cache openjdk8-jre-base git mercurial subversion openssh-client bash curl'
    ],
    setup_commands: [
      'sh -c "$(which dind) dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 --storage-driver=vfs" > /usr/local/bin/nohup.out 2>&1 &'
    ]
  },
  {
    distro: 'debian',
    version: '7',
    add_files: tini_and_gosu_add_file_meta,
    create_user_and_group: create_user_and_group_cmd,
    before_install: [
      "echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main' > /etc/apt/sources.list.d/webupd8team-java.list",
      'apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886',
      'apt-get update',
      'echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections',
      'apt-get install -y oracle-java8-installer git subversion mercurial openssh-client bash unzip curl',
      'apt-get autoclean'
    ]
  },
  {
    distro: 'debian',
    version: '8',
    add_files: tini_and_gosu_add_file_meta,
    create_user_and_group: create_user_and_group_cmd,
    before_install: [
      "echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list",
      'apt-get update',
      # see https://bugs.debian.org/775775
      # and https://github.com/docker-library/java/issues/19#issuecomment-70546872
      'apt-get install -y openjdk-8-jre-headless ca-certificates-java="20161107~bpo8+1" git subversion mercurial openssh-client bash unzip curl',
      'apt-get autoclean',
      # see comment above
      '/var/lib/dpkg/info/ca-certificates-java.postinst configure'
    ]
  },
  {
    distro: 'debian',
    version: '9',
    add_files: tini_and_gosu_add_file_meta,
    create_user_and_group: create_user_and_group_cmd,
    before_install: [
      'apt-get update',
      'apt-get install -y openjdk-8-jre-headless git subversion mercurial openssh-client bash unzip curl',
      'apt-get autoclean',
      '/var/lib/dpkg/info/ca-certificates-java.postinst configure'
    ]
  },
  {
    distro: 'ubuntu',
    version: '12.04',
    add_files: tini_and_gosu_add_file_meta,
    create_user_and_group: create_user_and_group_cmd,
    before_install: [
      "echo deb 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu precise main' > /etc/apt/sources.list.d/openjdk-ppa.list",
      'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
      'apt-get update',
      'apt-get install -y openjdk-8-jre-headless git subversion mercurial openssh-client bash unzip curl',
      'apt-get autoclean',
      # fix for https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/1396760
      '/var/lib/dpkg/info/ca-certificates-java.postinst configure'
    ]
  },
  {
    distro: 'ubuntu',
    version: '14.04',
    add_files: tini_and_gosu_add_file_meta,
    create_user_and_group: create_user_and_group_cmd,
    before_install: [
      "echo deb 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu trusty main' > /etc/apt/sources.list.d/openjdk-ppa.list",
      'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
      'apt-get update',
      'apt-get install -y openjdk-8-jre-headless git subversion mercurial openssh-client bash unzip curl',
      'apt-get autoclean',
      # fix for https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/1396760
      '/var/lib/dpkg/info/ca-certificates-java.postinst configure'
    ]
  },
  {
    distro: 'ubuntu',
    version: '16.04',
    add_files: tini_and_gosu_add_file_meta,
    create_user_and_group: create_user_and_group_cmd,
    before_install: [
      "echo deb 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu xenial main' > /etc/apt/sources.list.d/openjdk-ppa.list",
      'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
      'apt-get update',
      'apt-get install -y openjdk-8-jre-headless git subversion mercurial openssh-client bash unzip curl',
      'apt-get autoclean'
    ]
  },
  {
    distro: 'centos',
    version: '6',
    add_files: tini_and_gosu_add_file_meta,
    create_user_and_group: create_user_and_group_cmd,
    before_install: [
      'yum update -y',
      'yum install -y java-1.8.0-openjdk-headless git mercurial subversion openssh-clients bash unzip curl',
      'yum clean all'
    ]
  },
  {
    distro: 'centos',
    version: '7',
    add_files: tini_and_gosu_add_file_meta,
    create_user_and_group: create_user_and_group_cmd,
    before_install: [
      'yum update -y',
      'yum install -y java-1.8.0-openjdk-headless git mercurial subversion openssh-clients bash unzip curl',
      'yum clean all'
    ]
  }
].each do |image|
  distro = image[:distro]
  version = image[:version]
  image_tag = "v#{gocd_version}"
  before_install = image[:before_install]
  add_files = image[:add_files] || {}
  create_user_and_group = image[:create_user_and_group] || []
  setup_commands = image[:setup_commands] || []

  image_name = "gocd-agent-#{distro}-#{version}"
  repo_name = "docker-#{image_name}"
  dir_name = "build/#{repo_name}"
  repo_url = image[:repo_url] || "https://#{maybe_credentials}github.com/#{ENV['REPO_OWNER'] || 'gocd'}/#{repo_name}"

  namespace image_name do
    task :clean do
      rm_rf dir_name
    end

    task :init do
      sh(%(git clone --quiet "#{repo_url}" #{dir_name}))
    end

    task :create_dockerfile do
      docker_template = File.read('Dockerfile.erb')
      docker_renderer = ERB.new(docker_template, nil, '-')
      File.open("#{dir_name}/Dockerfile", 'w') do |f|
        f.puts(docker_renderer.result(binding))
      end

      readme_template = File.read("#{ROOT_DIR}/README.md.erb")
      readme_renderer = ERB.new(readme_template, nil, '-')
      File.open("#{dir_name}/README.md", 'w') do |f|
        f.puts(readme_renderer.result(binding))
      end

      cp "#{ROOT_DIR}/LICENSE-2.0.txt", "#{dir_name}/LICENSE-2.0.txt"
      Dir['*-logback-include.xml'].each do |f|
        cp f, "#{dir_name}"
      end
    end

    task :create_entrypoint_script do
      docker_template = File.read('docker-entrypoint.sh.erb')
      docker_renderer = ERB.new(docker_template, nil, '-')
      File.open("#{dir_name}/docker-entrypoint.sh", 'w') do |f|
        f.puts(docker_renderer.result(binding))
      end
      sh("chmod +x #{dir_name}/docker-entrypoint.sh")
    end

    task :build_docker_image do
      cd dir_name do
        sh("docker build . -t #{image_name}:#{ENV['TAG'] || image_tag}")
      end
    end

    task :commit_files do
      cd dir_name do
        sh('git add .')
        sh("git commit -m 'Update with GoCD Version #{gocd_version}' --author 'GoCD CI User <godev+gocd-ci-user@thoughtworks.com>'")
      end
    end

    task :create_tag do
      cd dir_name do
        sh("git tag '#{image_tag}'")
      end
    end

    task :git_push do
      cd dir_name do
        sh('git push')
        sh('git push --tags')
      end
    end

    task :docker_push_image_experimental => :build_image do
      org = ENV['EXP_ORG'] || 'gocdexperimental'
      tag = "v#{gocd_full_version}"
      sh("docker tag #{image_name}:#{image_tag} #{org}/#{image_name}:#{tag}")
      sh("docker push #{org}/#{image_name}:#{tag}")
    end

    task :docker_push_image_stable do
      org = ENV['ORG'] || 'gocd'
      experimental_org = ENV['EXP_ORG'] || 'gocdexperimental'
      sh("docker pull #{experimental_org}/#{image_name}:v#{gocd_full_version}")
      sh("docker tag #{experimental_org}/#{image_name}:v#{gocd_full_version} #{org}/#{image_name}:#{image_tag}")
      sh("docker push #{org}/#{image_name}:#{image_tag}")
    end

    desc "Publish #{image_name} to dockerhub"
    task publish: [:clean, :init, :create_dockerfile, :create_entrypoint_script, :commit_files, :create_tag, :git_push]

    desc "Build #{image_name} image locally"
    task build_image: [:clean, :init, :create_dockerfile, :create_entrypoint_script, :build_docker_image]
  end

  desc 'Publish all images to dockerhub'
  task publish: "#{image_name}:publish"

  desc 'Build all images locally'
  task build_image: "#{image_name}:build_image"

  desc "Push all images to experimental"
  task docker_push_experimental: "#{image_name}:docker_push_image_experimental"

  desc "Push all images to stable"
  task docker_push_stable: "#{image_name}:docker_push_image_stable"
end
