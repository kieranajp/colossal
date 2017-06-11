
describe process('python') do
  its(:user) { should eq 'app' }
  its(:args) { should contain /app.py/ }
  #its(:count) { should eq 1 }
end
