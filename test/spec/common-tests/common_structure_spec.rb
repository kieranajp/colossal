
describe 'version file exists' do
  describe file('/VERSION') do
    it { should be_file }
  end
end

describe 'app user ' do
  describe user('app') do
    it { should exist }
  end

  describe group('app') do
    it { should exist }
  end
end
