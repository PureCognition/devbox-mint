include apt
include stdlib
include vim

group{'devs':
	ensure => present
}

$password = hiera('password::user')

user{"ethan":
	ensure => present,
	shell => '/bin/bash',
	home => '/home/ethan',
	gid => 'devs',
	managehome => true,
	 password => generate('/bin/sh', '-c', "mkpasswd -m sha-512 ${password} | tr -d '\n'"),
	require => [Group['devs']]
}

Exec{
	path => [
		'/usr/local/bin',
		'/usr/bin',
		'/usr/sbin',
		'/bin',
		'/sbin',
	],
	logoutput => true
}

exec{'apt-get update':}
exec{'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3':}

package {'wget': ensure => installed}
package {'unzip': ensure => installed}
package {'terminator': ensure => installed}

class {'rvm_wrapper':
  require => [Package['curl'],Exec['gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3']] 
}

class { 'gvm' :
  owner   => 'ethan',
  group   => 'devs',
  homedir => '/home/ethan',
  require => [Package['wget'], Package['unzip'], User['ethan'], Group['devs'], Package['curl']]
}

gvm::package { 'springboot':
	version => '',#  hiera('version::spring-boot')
	require => Class['gvm']
}

class { 'springtoolsuite':
	require => [Package['curl']]
}

class { 'karaf':
  user => 'ethan',
  karafVersion => '3.0.3',
  tmpDir => '/tmp',
  require => [User['ethan']]
}
