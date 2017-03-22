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

[
  {
    distro: 'debian',
    version: '7',
    before_install: [
      "echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main' > /etc/apt/sources.list.d/webupd8team-java.list",
      'apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886',
      'apt-get update',
      'echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections',
      'apt-get install -y oracle-java8-installer git subversion mercurial openssh-client bash unzip',
      'apt-get autoclean'
    ]
  },
  {
    distro: 'debian',
    version: '8',
    before_install: [
      "echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list",
      'apt-get update',
      # see https://bugs.debian.org/775775
      # and https://github.com/docker-library/java/issues/19#issuecomment-70546872
      'apt-get install -y openjdk-8-jre-headless ca-certificates-java="20161107~bpo8+1" git subversion mercurial openssh-client bash unzip',
      'apt-get autoclean',
      # see comment above
      '/var/lib/dpkg/info/ca-certificates-java.postinst configure'
    ]
  },
  {
    distro: 'ubuntu',
    version: '12.04',
    before_install: [
      "echo deb 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu precise main' > /etc/apt/sources.list.d/openjdk-ppa.list",
      'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
      'apt-get update',
      'apt-get install -y openjdk-8-jre-headless git subversion mercurial openssh-client bash unzip',
      'apt-get autoclean',
      # fix for https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/1396760
      '/var/lib/dpkg/info/ca-certificates-java.postinst configure'
    ]
  },
  {
    distro: 'ubuntu',
    version: '14.04',
    before_install: [
      "echo deb 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu trusty main' > /etc/apt/sources.list.d/openjdk-ppa.list",
      'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
      'apt-get update',
      'apt-get install -y openjdk-8-jre-headless git subversion mercurial openssh-client bash unzip',
      'apt-get autoclean',
      # fix for https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/1396760
      '/var/lib/dpkg/info/ca-certificates-java.postinst configure'
    ]
  },
  {
    distro: 'ubuntu',
    version: '16.04',
    before_install: [
      "echo deb 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu xenial main' > /etc/apt/sources.list.d/openjdk-ppa.list",
      'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
      'apt-get update',
      'apt-get install -y openjdk-8-jre-headless git subversion mercurial openssh-client bash unzip',
      'apt-get autoclean'
    ]
  },
  {
    distro: 'centos',
    version: '6',
    before_install: [
      'yum update -y',
      'yum install -y java-1.8.0-openjdk-headless git mercurial subversion openssh-clients bash unzip',
      'yum clean all'
    ]
  },
  {
    distro: 'centos',
    version: '7',
    before_install: [
      'yum update -y',
      'yum install -y java-1.8.0-openjdk-headless git mercurial subversion openssh-clients bash unzip',
      'yum clean all'
    ]
  }
].each do |image|
  distro = image[:distro]
  version = image[:version]
  before_install = image[:before_install]

  image_name = "gocd-agent-#{distro}-#{version}"
  repo_name = "docker-#{image_name}"
  dir_name = "build/#{repo_name}"
  maybe_credentials = "#{ENV['GIT_USER']}:#{ENV['GIT_PASSWORD']}@" if ENV['GIT_USER'] && ENV['GIT_PASSWORD']
  repo_url = "https://#{maybe_credentials}github.com/#{ENV['REPO_OWNER'] || 'gocd'}/#{repo_name}"

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

      cp("#{ROOT_DIR}/docker-entrypoint.sh", "#{dir_name}/docker-entrypoint.sh")
      cp "#{ROOT_DIR}/LICENSE-2.0.txt", "#{dir_name}/LICENSE-2.0.txt"
    end

    task :build_docker_image do
      cd dir_name do
        sh("docker build . -t #{repo_name}")
      end
    end

    task :commit_dockerfile do
      cd dir_name do
        sh('git add .')
        sh("git commit -m 'Update with GoCD Version #{gocd_version}' --author 'GoCD CI User <godev+gocd-ci-user@thoughtworks.com>'")
      end
    end

    task :create_tag do
      cd dir_name do
        sh("git tag 'v#{gocd_version}'")
      end
    end

    task :git_push do
      cd dir_name do
        sh('git push')
        sh('git push --tags')
      end
    end

    desc "Publish #{image_name} to dockerhub"
    task publish: [:clean, :init, :create_dockerfile, :commit_dockerfile, :create_tag, :git_push]

    desc "Build #{image_name} image locally"
    task build_image: [:clean, :init, :create_dockerfile, :build_docker_image]
  end

  desc 'Publish all images to dockerhub'
  task publish: "#{image_name}:publish"

  desc 'Build all images locally'
  task build_image: "#{image_name}:build_image"
end
