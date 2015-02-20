include apt
include stdlib
include vim

group{'devs':
	ensure => present
}

$password = "$6$55EyhaQKjbOqHz$2onaeLwR97RHWMMTm0ufpRgWX7SYmMDF1h03RWMTZ00ldrKjwlJw9fkvMyj/EexoVFvkFDAvRMKtQx1dBdWTn0" #hiera('password::user')

user{"ethan":
	ensure => present,
	shell => '/bin/bash',
	home => '/home/ethan',
	gid => 'devs',
	managehome => true,
	password => $password,# generate('/bin/sh', '-c', "mkpasswd -m sha-512 ${password} | tr -d '\n'"),
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

exec{'sudo add-apt-repository ppa:webupd8team/sublime-text-2':}
exec{'apt-get update':
	require=> [Exec['sudo add-apt-repository ppa:webupd8team/sublime-text-2']]
}
exec{'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3':}

package {'wget': ensure => installed}
package {'unzip': ensure => installed}
package {'terminator': ensure => installed}
package {'sublime-text': 
	ensure => installed,
	require => [Exec['apt-get update']]
}

vcsrepo { "/home/ethan/dotfiles":
  ensure   => present,
  provider => git,
  source   => "git://github.com/ethanwinograd/dotfiles.git",
}

vcsrepo { "/home/ethan/scripts":
  ensure   => present,
  provider => git,
  source   => "git://github.com/ethanwinograd/scripts.git",
}


#exec{'cd /home/ethan && ./dotfiles/install_dotfiles.sh':}
#exec{'cd /home/ethan && ./scripts/vim_setup.sh':}
##exec{'cd /home/ethan && ./scripts/ruby_setup.sh':}


	


#class {'rvm_wrapper':
#  require => [Package['curl'],Exec['gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3']] 
#}

#class { 'gvm' :
#  owner   => 'ethan',
#  group   => 'devs',
#  homedir => '/home/ethan',
#  require => [Package['wget'], Package['unzip'], User['ethan'], Group['devs'], Package['curl']]
#}

#gvm::package { 'springboot':
#	version => '',#  hiera('version::spring-boot')
#	require => Class['gvm']
#}

class { 'sts':
	#require => [Package['curl']]
}

#class {'karaf':
#  user => 'ethan',
#  karafVersion => '3.0.3',
#  tmpDir => '/tmp',
#  require => [User['ethan']]
#}
