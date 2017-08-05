require_relative '../../helper_spec.rb'

describe 'service pilot-app' do
  describe 'definition by name' do
    describe command 'curl -s -v http://127.0.0.1:8500/v1/catalog/service/pilot-app' do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should contain '"ServiceName":"pilot-app"' }
      its(:stdout) { should contain '"ServiceTags":\["TEST","v1.1.1","Development"]'}
      its(:stdout) { should contain '"ServicePort":8889' }
    end
  end

  describe 'health is passing' do
    describe command 'curl -s -v http://127.0.0.1:8500/v1/health/service/pilot-app' do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should contain '"Service":"pilot-app"' }
      its(:stdout) { should contain '"Status":"passing"' }
    end
  end
end

describe 'service dependency' do
  describe 'localport 6379 is open by haproxy' do
    describe port(6379) do
      it { should be_listening.on('127.0.0.1').with('tcp') }
    end
  end
end
