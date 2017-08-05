require_relative '../../helper_spec.rb'

describe file('/var/log/hooks.log') do
  it { should contain '/hooks/preStart running' }
  it { should contain '/hooks/renderConfigFiles running' }
  it { should contain '/hooks/preChange running' }
  it { should contain '/hooks/postChange running' }
  it { should contain 'COLOSSAL=SOMETHONING' }
  # it { should contain '/hooks/preStop running' }
  # it { should contain '/hooks/postStop running' }
end
