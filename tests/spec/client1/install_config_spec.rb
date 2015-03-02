require 'spec_helper'

describe package('rsyslog') do
    it { should be_installed }
end

describe service('rsyslog') do
    it { should be_enabled }
    it { should be_running }
end

describe file('/etc/rsyslog.conf') do
    it { should be_file }
    it { should be_mode 400 }
    it { should be_owned_by 'root' }
end

describe file('/etc/rsyslog.d') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
end

describe file('/etc/rsyslog.d/00-client_header.conf') do
    it { should be_file }
    it { should be_mode 400 }
    it { should be_owned_by 'root' }
end

describe file('/etc/rsyslog.d/98-client_footer.conf') do
    it { should be_file }
    it { should be_mode 400 }
    it { should be_owned_by 'root' }
end

describe file('/etc/rsyslog.d/99-all.conf') do
    it { should be_file }
    it { should be_mode 400 }
    it { should be_owned_by 'root' }
end

describe host('172.20.20.20') do
  it { should be_reachable }
  it { should be_reachable.with( :port => 514 ) }
  it { should be_reachable.with( :port => 514, :proto => 'tcp' ) }
  it { should be_reachable.with( :port => 514, :proto => 'udp' ) }
end
