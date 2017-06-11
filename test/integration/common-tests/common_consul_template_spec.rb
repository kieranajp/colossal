require_relative '../helper_spec.rb'

describe 'Consul template' do
  describe 'Consul binary file' do
    describe file '/usr/local/bin/consul' do
      it { should be_file }
      it { should be_executable }
    end
  end
end
