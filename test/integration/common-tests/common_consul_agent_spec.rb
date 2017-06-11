require_relative '../helper_spec.rb'

describe 'consul user ' do
  describe user('consul') do
    it { should exist }
  end

  describe group('consul') do
    it { should exist }
  end
end

describe 'consul agent' do
  describe process('consul') do
    its(:args) { should contain 'agent' }
  end

  %w(/consul/config /consul/data).each do |dir|
    describe file(dir) do
      it { should be_directory }
    end
  end

  %w(8500 8600).each do |port|
    describe port(port) do
      it { should be_listening.on('127.0.0.1').with('tcp') }
    end
  end

  describe 'UI should be disabled' do
    describe command 'curl -s -I http://127.0.0.1:8500/ui/' do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should contain 'HTTP/1.1 404 Not Found' }
    end
  end

  describe 'Consul binary file' do
    describe file '/usr/local/bin/consul' do
      it { should be_file }
      it { should be_executable }
    end
  end

  describe command 'consul info' do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should contain 'known_servers = 1' }
    its(:stdout) { should contain 'server = false' }
    #services = 0 # later
  end


end
