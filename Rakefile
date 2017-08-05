require 'docker'
require 'json'
require 'rspec/core/rake_task'

task default: %w[tests]

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

def print_title(msg)
  puts '', "#{ARROW} #{msg} ..."
end

def print_msg(msg)
  puts " => #{msg}"
end

def remove_image(name, force)
  return false unless Docker::Image.exist?(name)
  print_msg("Removing image #{name}")
  Docker::Image.remove(name, :force => force)
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
  abort("Container not running #{name}") unless container_id
  ENV['KITCHEN_CONTAINER_ID'] = container_id
  print_title("Running tests for #{name}")
  RSpec::Core::RakeTask.new(name) do |t|
    t.pattern = path
  end
  Rake::Task[name].execute
end

#
# TASKS
#

desc 'Run test on app'
task :'verify-app' do
  run_test('test_app', 'test/spec/app/*_spec.rb')
end

desc 'Run test on redis'
task :'verify-redis' do
  run_test('test_redis', 'test/spec/redis/*_spec.rb')
end

desc 'Run test on nginx'
task :'verify-nginx' do
  run_test('test_nginx', 'test/spec/nginx/*_spec.rb')
end

desc 'Run test on hooks'
task :'verify-hooks' do
  run_test('test_hooks', 'test/spec/hooks/*_spec.rb')
end

desc 'Verify tests'
task :verify => %w[verify-redis verify-app verify-nginx verify-hooks] do
  Rake::Task['compose-down'].execute
end

desc 'Build, bring up cluser, test, destroy'
task :tests => %w[build compose-down compose-build compose-up sleep verify] do
  # Lets destroy hooks
  # container_id = container_running?("test_hooks")
  # if container_id
  #   container = Docker::Container.get(container_id)
  #   container.exec(['/kill.sh'])
  # end
  # #puts container.logs(stdout: true)

  # Destroy
  Rake::Task['compose-down'].execute
end

desc 'Build Colossal docker container'
task :build do
  print_title("Building #{NAME}:#{VERSION}, #{NAME}:#{CI_LABEL} and #{NAME}:dev …")
  sh "docker build #{BUILD_ARGS} -t #{NAME}:dev -t #{NAME}:#{CI_LABEL} -t #{NAME}:#{VERSION} -f Dockerfile ."
end

desc 'Squash Colossal to one layer'
task :squash do
  # requires docker-squash https://github.com/goldmann/docker-squash
  print_title("Squashing #{NAME}:#{VERSION} #{NAME}:dev #{NAME}:#{CI_LABEL}")
  sh "docker-squash -t #{NAME}:#{VERSION} #{NAME}:#{VERSION}"
  sh "docker tag #{NAME}:#{VERSION} #{NAME}:dev"
  sh "@docker tag #{NAME}:#{VERSION} #{NAME}:#{CI_LABEL}"
end

desc 'Build test cluster'
task :'compose-build' do
  abort("#{NAME}:dev is not yet built. Run 'rake build'") unless Docker::Image.exist?("#{NAME}:dev")
  print_title('Building test cluster')
  sh 'cd test; docker-compose build'
end

desc 'Sleep for a while'
task :sleep do
  print_title('Sleeping for a bit')
  sh 'sleep 15'
end

desc 'Bring up test cluster'
task :'compose-up' do
  abort("#{NAME}:dev is not yet built. Run 'rake build'") unless Docker::Image.exist?("#{NAME}:dev")
  print_title('Bring up test cluster')
  sh 'cd test; docker-compose up -d'
end

desc 'Teardown test cluster'
task :'compose-down' do
  print_title('Teardown container')
  sh 'cd test; docker-compose down'
end

task :clean => :'compose-down'

desc 'Clean all traces'
task :'clean-all' => :'compose-down' do
  print_title('Removing images')
  remove_image('test_app:latest', true)
  remove_image('test_redis:latest', true)
  remove_image('test_nginx:latest', true)
  remove_image('test_hooks:latest', true)
  remove_image("#{NAME}:#{VERSION}", true)
  remove_image("#{NAME}:dev", true)
  remove_image("#{NAME}:latest", true)
  remove_image("#{NAME}:pr", true)
  remove_image('consul:latest', true)
  dangling_images = `docker images -f "dangling=true" -q`
  dangling_images.each_line do |image|
    remove_image(image.delete!("\n"), true)
  end
end

desc "Push #{NAME}:#{VERSION}"
task :push do
  print_title("Pushing #{NAME}:#{VERSION}")
  sh "docker tag #{NAME}:dev #{NAME}:#{VERSION}"
  sh "docker push #{NAME}:#{VERSION}"
end

desc "Push #{NAME}:#{VERSION}"
task :'push-label' do
  print_title("Pushing #{NAME}:#{CI_LABEL}")
  sh "docker tag #{NAME}:dev #{NAME}:#{CI_LABEL}"
  sh "docker push #{NAME}:#{CI_LABEL}"
end

desc "Link #{NAME}:#{VERSION} to #{NAME}:latest and push it"
task :'push-label' do
  print_title("Pushing #{NAME}:#{CI_LABEL}")
  sh "docker tag #{NAME}:#{VERSION} #{NAME}:latest"
  sh "docker push #{NAME}:latest"
end
