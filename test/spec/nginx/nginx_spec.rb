require_relative '../../helper_spec.rb'

describe process('nginx') do
  it { should be_running }
end

describe command 'curl http://localhost:8888/status' do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain 'healthy' }
end

describe 'app accessiable via /' do
  describe command 'curl http://localhost:8888/' do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should contain 'Hello World! I am' }
    its(:stdout) { should contain 'times' }
  end
end
