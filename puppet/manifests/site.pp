include apt
include stdlib
include vim

group{'admin':
	ensure => present
}

$password = '$6$55EyhaQKjbOqHz$2onaeLwR97RHWMMTm0ufpRgWX7SYmMDF1h03RWMTZ00ldrKjwlJw9fkvMyj/EexoVFvkFDAvRMKtQx1dBdWTn0'
#hiera('password::user')

user{"ethan":
	ensure => present,
	shell => '/bin/bash',
	home => '/home/ethan',
	gid => 'admin',
	managehome => true,
	password => $password,
	require => [Group['admin']]
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

exec{ "/bin/chown ethan /home/ethan":
  require => [User['ethan']]
}


exec{ "/bin/bash ./dotfiles/install_dotfiles.sh":
	user => ethan,
	cwd => "/home/ethan",
	require => [User['ethan']]
}

exec{ "/bin/bash ./scripts/vim_setup.sh":
	user => ethan,
	cwd => "/home/ethan",
	require => [User['ethan']]
}



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

class { 'sts':}

#class {'karaf':
#  user => 'ethan',
#  karafVersion => '3.0.3',
#  tmpDir => '/tmp',
#  require => [User['ethan']]
#}
