# Class: sts
#
# This module manages SpringSource Tool Suite
#
class sts {
	$sts_url = hiera('url::sts')
	$sts_version = hiera('version::sts')
	$eclipse_release = hiera('version::eclipse::release')
	$eclipse_minor_release = hiera('version::eclipse::release::minor') 
	$eclipse_version = "${eclipse_release}.${$eclipse_minor_release}"
	$sts_tarball = "/tmp/sts-${sts_version}.tar.gz"
	$flavor = $architecture ? {
		"amd64" => "-x86_64",
		default => "" 
	}
	$sts_install = "/opt"
	$sts_home = "${sts_install}/springsource/sts-${sts_version}.RELEASE"
	#http://download.springsource.com/release/STS/3.6.3.SR1/dist/e4.4/spring-tool-suite-3.6.3.SR1-e4.4.1-linux-gtk.tar.gz
	#$sts_url = "http://download.springsource.com/release/STS/${sts_version}/dist/e${eclipse_release}/springsource-tool-suite-${sts_version}.RELEASE-e${eclipse_version}-linux-gtk${flavor}.tar.gz"
	$sts_symlink = "${sts_install}/sts"
	$sts_executable = "${sts_symlink}/STS"
	
	exec { "download-sts":
		command => "/usr/bin/wget -O ${sts_tarball} ${sts_url}",
		require => Package["wget"],
		creates => $sts_tarball,
		timeout => 1200,	
	}
	
	file { "${sts_tarball}" :
		require => Exec["download-sts"],
		ensure => file,
	}
	
	exec { "install-sts" :
		require => File["${sts_tarball}"],
		cwd => $sts_install,
		command => "/bin/tar -xa -f ${sts_tarball}",
		creates => $sts_home,
	}
	
	file { $sts_home :
		ensure => directory,
		require => Exec["install-sts"],
	}

	file { $sts_symlink :
		ensure => link,
		target => $sts_home,
		require => File[$sts_home],
	}
	
	file { "/usr/share/icons/sts.xpm":
		ensure => link,
		target => "${sts_home}/icon.xpm",
		require => File[$sts_home],	
	}
	
	file { "/usr/share/applications/sts.desktop" :
		require => File[$sts_symlink],
		content => template('sts/sts.desktop.erb'),
	}	


}
