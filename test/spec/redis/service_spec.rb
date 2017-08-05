require_relative '../../helper_spec.rb'

describe 'service pilot-redus' do
  describe 'definition by name' do
    describe command 'curl -s -v http://127.0.0.1:8500/v1/catalog/service/pilot-redis' do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should contain '"ServiceName":"pilot-redis"' }
      its(:stdout) { should contain '"ServiceTags":\[]' }
      its(:stdout) { should contain '"ServicePort":6379' }
    end
  end

  describe 'health is passing' do
    describe command 'curl -s -v http://127.0.0.1:8500/v1/health/service/pilot-redis' do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should contain '"Service":"pilot-redis"' }
      its(:stdout) { should contain '"Status":"passing"' }
    end
  end
end
