require_relative '../../helper_spec.rb'

describe 'service pilot-nginx' do
  describe 'definition by name' do
    describe command 'curl -s -v http://127.0.0.1:8500/v1/catalog/service/pilot-nginx' do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should contain '"ServiceName":"pilot-nginx"' }
      its(:stdout) { should contain '"ServiceTags":\[]' }
      its(:stdout) { should contain '"ServicePort":8888' }
    end
  end

  describe 'health is passing' do
    describe command 'curl -s -v http://127.0.0.1:8500/v1/health/service/pilot-nginx' do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should contain '"Service":"pilot-nginx"' }
      its(:stdout) { should contain '"Status":"passing"' }
    end
  end
end

describe 'service dependency' do
  describe 'localport 8889 is open by haproxy' do
    describe port(8889) do
      it { should be_listening.on('127.0.0.1').with('tcp') }
    end
  end
end
