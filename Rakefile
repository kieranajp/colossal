require 'docker'
require 'json'
require 'rspec/core/rake_task'

task default: %w[help]

PATH    = File.dirname(__FILE__)
NAME    = 'quay.io/ahelal/colossal'.freeze
VERSION = File.read(PATH + '/VERSION').delete!("\n")
PACKAGES = JSON.parse(File.read(PATH + '/packages.json'))
BUILD_ARGS = "--build-arg VERSION=#{VERSION}" \
             " --build-arg CONTAINERPILOT_VERSION=#{PACKAGES['CONTAINERPILOT_VERSION']}" \
             " --build-arg CONTAINERPILOT_CHECKSUM=#{PACKAGES['CONTAINERPILOT_CHECKSUM']}" \
             " --build-arg CONSUL_VERSION=#{PACKAGES['CONSUL_VERSION']}" \
             " --build-arg CONSUL_CHECKSUM=#{PACKAGES['CONSUL_CHECKSUM']}" \
             " --build-arg CONSUL_TEMPLATE_VERSION=#{PACKAGES['CONSUL_TEMPLATE_VERSION']}" \
             " --build-arg CONSUL_TEMPLATE_CHECKSUM=#{PACKAGES['CONSUL_TEMPLATE_CHECKSUM']}" \
             " --build-arg RESU_VERSION=#{PACKAGES['RESU_VERSION']}" \
             " --build-arg RESU_CHECKSUM=#{PACKAGES['RESU_CHECKSUM']}" \
             " --build-arg PROMETHEUS_HAPROXY_VERSION=#{PACKAGES['PROMETHEUS_HAPROXY_VERSION']}" \
             " --build-arg PROMETHEUS_HAPROXY_CHECKSUM=#{PACKAGES['PROMETHEUS_HAPROXY_CHECKSUM']}" \
				     " --build-arg CONSUL_TEMPLATE_PLUGIN_SSM_VERSION=#{PACKAGES['CONSUL_TEMPLATE_PLUGIN_SSM_VERSION']}" \
				     " --build-arg CONSUL_TEMPLATE_PLUGIN_SSM_CHECKSUM=#{PACKAGES['CONSUL_TEMPLATE_PLUGIN_SSM_CHECKSUM']}".freeze
ARROW = "\033[34;1m▶\033[0m".freeze
CI_LABEL = 'pr'

def print_msg(msg)
  puts '', "#{ARROW} #{msg} ...", ''
end

def container_running?(name)
  Docker::Container.all.each do |container|
    container_id = Docker::Container.get(container.id)
    container_name = container_id.json['Config']['Image']
    return container.id if container_name == name
  end
  false
end

def run_test(name, path)
  container_id = container_running?(name)
  raise "Container not running #{name}" unless container_id
  ENV['KITCHEN_CONTAINER_ID'] = container_id
  print_msg("Running tests for #{name}")
  RSpec::Core::RakeTask.new(name) do |t|
    t.pattern = path
  end
  Rake::Task[name].execute
end

task :'test-app' do
  run_test('test_app', 'test/spec/app/*_spec.rb')
end

task :'test-redis' do
  run_test('test_redis', 'test/spec/redis/*_spec.rb')
end

task :'test-nginx' do
  run_test('test_nginx', 'test/spec/nginx/*_spec.rb')
end

task :tests => %w[build compose_down compose_up test-redis test-app test-nginx] do
  Rake::Task['compose_down'].execute
end

desc 'Start consul server'
task :build do
  print_msg("Building #{NAME}:#{VERSION}, #{NAME}:#{CI_LABEL} and #{NAME}:dev …")
  sh "docker build #{BUILD_ARGS} -t #{NAME}:dev -t #{NAME}:#{CI_LABEL} -t #{NAME}:#{VERSION} -f Dockerfile ."
end

desc 'Build Colossal docker container'
task :build do
  print_msg("Building #{NAME}:#{VERSION}, #{NAME}:#{CI_LABEL} and #{NAME}:dev …")
  sh "docker build #{BUILD_ARGS} -t #{NAME}:dev -t #{NAME}:#{CI_LABEL} -t #{NAME}:#{VERSION} -f Dockerfile ."
end

desc 'Build and bring up all containers'
task :compose_up do
  print_msg('Bring up all containers')
  sh 'cd test; docker-compose up --build  -d; sleep 20'
end

desc 'Teardown container'
task :compose_down do
  print_msg('Teardown container')
  sh 'cd test; docker-compose down'
end
