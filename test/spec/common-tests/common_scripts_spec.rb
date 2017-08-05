binaries = ['haproxy-manage.sh', 'changed-script.sh', 'postStop-script.sh',
            'preStart-script.sh', 'preStop-script.sh']

binaries.each do |binary|
  describe "#{binary} file exists" do
    describe file "/usr/local/bin/#{binary}" do
      it { should be_file }
      it { should be_executable }
    end
  end
end
