
describe process('python') do
  its(:user) { should eq 'app' }
  its(:args) { should contain /app.py/ }
  #its(:count) { should eq 1 }
end

describe 'ENV Varialbe defined by container env put' do
  describe command 'curl -s -v http://127.0.0.1:8889/env' do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should contain 'ENV=CONTAINERPILOT' }
  end
end
