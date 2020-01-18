# InSpec test for recipe docker-prometheus::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

describe user('prometheus') do
  it { should exist }
  its('group') { should cmp 'prometheus' }
  its('home') { should cmp '/opt/prometheus' }
end
describe group('prometheus') do
  it { should exist }
  its('members') { should cmp 'prometheus,root' }
end

# directories
%w(
  /opt/prometheus
  /opt/prometheus/console_libraries
  /opt/prometheus/consoles
  /opt/prometheus/data
  /etc/prometheus
  /etc/prometheus/rules
).each do |prom_dir|
  describe directory(prom_dir) do
    it { should exist }
    it { should be_directory }
    its('owner') { should cmp 'prometheus' }
    its('group') { should cmp 'prometheus' }
  end
end

# config
%w(
  /etc/prometheus/prometheus.yml
  /etc/prometheus/rules/default.yml
).each do |prom_file|
  describe file(prom_file) do
    it { should exist }
    it { should be_file }
    its('owner') { should cmp 'prometheus' }
    its('group') { should cmp 'prometheus' }
  end
end

# executables
%w(
  /opt/prometheus/prometheus
  /entrypoint.sh
).each do |prom_exec|
  describe file(prom_exec) do
    it { should exist }
    it { should be_file }
    it { should be_executable.by_user('root') }
    it { should be_executable.by_user('prometheus') }
  end
end

# validate version
describe command('/opt/prometheus/prometheus --version 2>&1') do
  its('stdout') { should cmp /(2.15.2)/ }
end
