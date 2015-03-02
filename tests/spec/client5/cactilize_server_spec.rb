require 'spec_helper'

describe package('apache2') do
    it { should be_installed }
end

describe service('apache2') do
    it { should be_enabled }
    it { should be_running }
end

describe package('mysql-server') do
    it { should be_installed }
end

describe service('mysql') do
    it { should be_enabled }
    it { should be_running }
end

describe port('80') do
    it { should be_listening.with('tcp') }
end

describe file('/etc/cacti') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
end

describe file('/etc/cacti/config.php') do
    it { should be_file }
    it { should be_mode 440 }
    it { should be_owned_by 'cacti' }
end

describe file('/etc/cacti/apache.conf') do
    it { should be_file }
    it { should be_mode 440 }
    it { should be_owned_by 'root' }
end

describe file('/etc/cacti/ss_get_by_ssh.php.cnf') do
    it { should be_file }
    it { should be_mode 440 }
    it { should be_owned_by 'cacti' }
end

describe file('/etc/cacti/ss_get_mysql_stats.php.cnf') do
    it { should be_file }
    it { should be_mode 440 }
    it { should be_owned_by 'cacti' }
end

describe file('/etc/cacti/.ssh') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'cacti' }
end

describe file('/etc/cacti/.ssh/id_rsa') do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'cacti' }
end

describe file('/etc/cacti/.ssh/id_rsa.pub') do
    it { should be_file }
    it { should be_mode 0644 }
    it { should be_owned_by 'cacti' }
end

describe file('/usr/share/cacti') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'cacti' }
end

describe host('172.20.20.20') do
  it { should be_reachable }
  it { should be_reachable.with( :port => 80, :proto => 'tcp' ) }
end
