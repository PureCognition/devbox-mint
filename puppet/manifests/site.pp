include apt
include stdlib
include vim

group{'admin':
	ensure => present
}

group{'vboxsf':
	ensure => present
}

#pwd is: 'changeme'
$password='$6$ccsvgLY33PNZ48x6$kM6DHTjtkcxOfvs/qTR/92RRxPJuNqjGTLeOal8K0d.5XjiwWhuI/ghHlandEqo2U5ajIr89vAxmDLcc6F2Zd.'

$user = hiera('password::user')

user{"${user}":
	ensure => present,
	shell => '/bin/bash',
	home => "/home/${user}",
	gid => 'admin',
	managehome => true,
	password => $password,
	require => [Group['admin'],Group['vboxsf']]
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

vcsrepo { "/home/${user}/dotfiles":
  ensure   => present,
  provider => git,
  source   => "git://github.com/ethanwinograd/dotfiles.git",
}

vcsrepo { "/home/${user}/scripts":
  ensure   => present,
  provider => git,
  source   => "git://github.com/ethanwinograd/scripts.git",
}

exec{ "/bin/chown ${user} /home/${user}":
  require => [User["${user}"]]
}


exec{ "/bin/bash ./dotfiles/install_dotfiles.sh":
	user => $user,
	cwd => "/home/${user}",
	require => [User["${user}"]]
}

exec{ "/bin/bash ./scripts/vim_setup.sh":
	user => $user,
	cwd => "/home/${user}",
	require => [User["${user}"]]
}

class { 'sts':}

#class {'rvm_wrapper':
#  require => [Package['curl'],Exec['gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3']] 
#}

#class { 'gvm' :
#  owner   => '${user}',
#  group   => 'devs',
#  homedir => '/home/${user}',
#  require => [Package['wget'], Package['unzip'], User['${user}'], Group['devs'], Package['curl']]
#}

#gvm::package { 'springboot':
#	version => '',#  hiera('version::spring-boot')
#	require => Class['gvm']
#}


#class {'karaf':
#  user => '${user}',
#  karafVersion => '3.0.3',
#  tmpDir => '/tmp',
#  require => [User['${user}']]
#}
