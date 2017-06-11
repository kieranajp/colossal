require_relative '../../helper_spec.rb'

describe process('redis-server') do
  it { should be_running }
end

describe command 'redis-cli ping' do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain 'PONG' }
end

