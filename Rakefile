# Copyright 2018 ThoughtWorks, Inc.
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

def versionFile(name)
  version_file_location = ENV["VERSION_FILE_LOCATION"] || 'version.json'
  JSON.parse(File.read(version_file_location))[name] if File.file?(version_file_location)
end

def get_var(name)
  value = ENV[name]
  raise "\e[1;31m[ERROR]\e[0m  Environment #{name} not specified!" if value.to_s.strip.empty?
  value
end

class Docker
  def self.login
    token = ENV["TOKEN"]
    if token
      FileUtils.mkdir_p "#{Dir.home}/.docker"
      File.open("#{Dir.home}/.docker/config.json", "w") do |f|
        f.write({:auths => {"https://index.docker.io/v1/" => {:auth => token}}}.to_json)
      end
    else
      puts "\e[1;33m[WARN]\e[0m Skipping docker login as environment variable TOKEN is not specified."
    end
  end
end

gocd_full_version = versionFile('go_full_version') || get_var('GOCD_FULL_VERSION')
gocd_version = versionFile('go_version') || get_var('GOCD_VERSION')
gocd_git_sha = versionFile('git_sha') || get_var('GOCD_GIT_SHA')
remove_image_post_push = ENV['CLEAN_IMAGES'] || true
is_stable_release = ENV['GOCD_STABLE_RELEASE'] == "true" || false
download_url = ENV['GOCD_AGENT_DOWNLOAD_URL'] || "https://download.gocd.org#{is_stable_release ? "/" : "/experimental/" }binaries/#{gocd_full_version}/generic/go-agent-#{gocd_full_version}.zip"

# Perform docker login if token is specified
Docker.login

ROOT_DIR = Dir.pwd

def tini_assets
  @tini_assets ||= JSON.parse(open('https://api.github.com/repos/krallin/tini/releases/latest').read)['assets']
end

def gosu_assets
  @gosu_assets ||= JSON.parse(open('https://api.github.com/repos/tianon/gosu/releases/latest').read)['assets']
end

def tini_url
  tini_assets.find {|asset| asset['browser_download_url'] =~ /tini-static-amd64$/}['browser_download_url']
end

def gosu_url
  gosu_assets.find {|asset| asset['browser_download_url'] =~ /gosu-amd64$/}['browser_download_url']
end

tini_and_gosu_add_file_meta = {
    '/usr/local/sbin/tini' => {url: tini_url, mode: '0755', owner: 'root', group: 'root'},
    '/usr/local/sbin/gosu' => {url: gosu_url, mode: '0755', owner: 'root', group: 'root'}
}

create_user_and_group_cmd = [
    'groupadd -g ${GID} go',
    'useradd -u ${UID} -g go -d /home/go -m go'
]

maybe_credentials = "#{ENV['GIT_USER']}:#{ENV['GIT_PASSWORD']}@" if ENV['GIT_USER'] && ENV['GIT_PASSWORD']

agents = [
    {
        distro: 'alpine',
        version: '3.5',
        release_name: '3.5',
        eol_date: '2018-11-01',
        continue_to_build: true,
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
        release_name: '3.6',
        eol_date: '2019-05-01',
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
        release_name: '3.7',
        eol_date: '2019-11-01',
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
        version: '3.8',
        release_name: '3.8',
        eol_date: '2020-05-01',
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
        release_name: 'dind',
        eol_date: '2099-01-01',
        add_files: tini_and_gosu_add_file_meta,
        needs_privileged_mode: true,
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
            'sh -c "$(which dind) dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375" > /usr/local/bin/nohup.out 2>&1 &'
        ]
    },
    {
        distro: 'debian',
        version: '8',
        release_name: 'jessie',
        eol_date: '2020-06-30',
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
        release_name: 'stretch',
        eol_date: '2022-06-30',
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
        version: '14.04',
        release_name: 'trusty',
        eol_date: '2019-04-01',
        add_files: tini_and_gosu_add_file_meta,
        create_user_and_group: create_user_and_group_cmd,
        before_install: [
            "echo deb 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu trusty main' > /etc/apt/sources.list.d/openjdk-ppa.list",
            'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
            'apt-get update',
            'apt-get install -y openjdk-10-jre-headless git subversion mercurial openssh-client bash unzip curl',
            'apt-get autoclean',
            # fix for https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/1396760
            '/var/lib/dpkg/info/ca-certificates-java.postinst configure'
        ]
    },
    {
        distro: 'ubuntu',
        version: '16.04',
        release_name:'xenial',
        eol_date: '2021-04-01',
        add_files: tini_and_gosu_add_file_meta,
        create_user_and_group: create_user_and_group_cmd,
        before_install: [
            "echo deb 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu xenial main' > /etc/apt/sources.list.d/openjdk-ppa.list",
            'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
            'apt-get update',
            'apt-get install -y openjdk-10-jre-headless git subversion mercurial openssh-client bash unzip curl',
            'apt-get autoclean'
        ]
    },
    {
        distro: 'ubuntu',
        version: '18.04',
        release_name:'bionic',
        eol_date: '2023-04-01',
        add_files: tini_and_gosu_add_file_meta,
        create_user_and_group: create_user_and_group_cmd,
        before_install: [
            'apt-get update',
            'apt-get install -y default-jre-headless git subversion mercurial openssh-client bash unzip curl',
            'apt-get autoclean'
        ]
    },
    {
        distro: 'centos',
        version: '6',
        release_name:'6',
        eol_date: '2020-11-01',
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
        release_name:'7',
        eol_date: '2024-06-01',
        add_files: tini_and_gosu_add_file_meta,
        create_user_and_group: create_user_and_group_cmd,
        before_install: [
            'yum update -y',
            'yum install -y java-1.8.0-openjdk-headless git mercurial subversion openssh-clients bash unzip curl',
            'yum clean all'
        ]
    },	
    {
        distro: 'fedora',
        version: '29',
        release_name:'29',
        eol_date: '2019-11-30',
        add_files: tini_and_gosu_add_file_meta,
        create_user_and_group: create_user_and_group_cmd,
        before_install: [
            'yum update -y',
            'yum install -y java-11-openjdk-headless git mercurial subversion openssh-clients bash unzip curl',
            'yum clean all'
        ]
    }
]

total_workers = (ENV['GO_JOB_RUN_COUNT'] || '1').to_i
agents_per_worker = (agents.size.to_f / total_workers).ceil
current_worker_index = (ENV['GO_JOB_RUN_INDEX'] || '1').to_i
agents_to_build = agents.each_slice(agents_per_worker).to_a[current_worker_index - 1]

agents_to_build.each do |image|
  distro = image[:distro]
  version = image[:version]
  release_name = image[:release_name]
  image_tag = "v#{gocd_version}"
  before_install = image[:before_install]
  add_files = image[:add_files] || {}
  create_user_and_group = image[:create_user_and_group] || []
  setup_commands = image[:setup_commands] || []
  eol_date = Date.strptime(image[:eol_date], '%Y-%m-%d')
  about_to_eol = (eol_date - Date.today) <= 95
  needs_privileged_mode = image[:needs_privileged_mode] || false

  if eol_date <= Date.today
    raise "The image #{distro}:#{version} is unsupported EOL was #{eol_date}."
  end

  if about_to_eol && !image[:continue_to_build]
    raise "The image #{distro}:#{version} is supposed to be EOL in #{(eol_date - Date.today).to_i} day(s), on #{eol_date}. Set :continue_to_build option to continue building."
  end

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
      sh("docker rmi -f #{org}/#{image_name}:#{tag} #{image_name}:#{image_tag} #{distro}:#{version}") if remove_image_post_push
    end

    task :docker_push_image_stable do
      org = ENV['ORG'] || 'gocd'
      tag = "v#{gocd_full_version}"
      experimental_org = ENV['EXP_ORG'] || 'gocdexperimental'
      sh("docker pull #{experimental_org}/#{image_name}:v#{gocd_full_version}")
      sh("docker tag #{experimental_org}/#{image_name}:v#{gocd_full_version} #{org}/#{image_name}:#{image_tag}")
      sh("docker push #{org}/#{image_name}:#{image_tag}")
      sh("docker rmi -f #{org}/#{image_name}:#{tag} #{experimental_org}/#{image_name}:v#{gocd_full_version} #{distro}:#{version}") if remove_image_post_push
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
