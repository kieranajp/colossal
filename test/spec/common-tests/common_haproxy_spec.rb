describe 'HA Proxy consul template file' do
  describe file('/etc/haproxy.ctmpl') do
    it { should be_file }
  end
end

describe process('/usr/sbin/haproxy') do
  its(:args) { should contain 'haproxy.pid' }
end
