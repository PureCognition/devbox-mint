include apt
include stdlib
include vim

group{'devs':
	ensure => present
}

user{"ethan":
	ensure => present,
	shell => '/bin/bash',
	home => '/home/ethan',
	gid => 'devs',
	managehome => true,
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

package {'wget':
	ensure => installed
}

package {'unzip':
	ensure => installed
}

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
