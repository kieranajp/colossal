
describe 'containerpilot binary exists' do
  describe file '/bin/containerpilot' do
    it { should be_file }
    it { should be_executable }
  end
end

describe 'Container pilot JSON5' do
  describe file('/etc/containerpilot.json5') do
    it { should be_file }
  end
end

describe process('containerpilot') do
  its(:args) { should contain '/etc/containerpilot.json5' }
end
