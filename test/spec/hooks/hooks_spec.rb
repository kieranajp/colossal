require_relative '../../helper_spec.rb'

describe file('/var/log/containerpilot.log') do
  it { should contain 'Hook /hooks/preStart running' }
end

describe file('/var/log/containerpilot.log') do
  it { should contain 'Hook /hooks/renderConfigFiles running' }
end

describe file('/var/log/containerpilot.log') do
  it { should contain 'Hook /hooks/preChange running' }
end

describe file('/var/log/containerpilot.log') do
  it { should contain 'Hook /hooks/postChange running' }
end

describe file('/var/log/containerpilot.log') do
  it { should contain 'Hook /hooks/preStop running' }
end

describe file('/var/log/containerpilot.log') do
  it { should contain 'Hook /hooks/postStop running' }
end

describe file('/var/log/containerpilot.log') do
  it { should contain 'Setting up env COLOSSAL' }
end
