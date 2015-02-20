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
	$sts_tarball = hiera('url::sts::filename')
	
	$flavor = $architecture ? {
		"amd64" => "-x86_64",
		default => "" 
	}
	$sts_install = "/opt"
	$sts_home = "${sts_install}/sts-bundle/sts-${sts_version}.SR1"
	
	$sts_symlink = "${sts_install}/sts"
	$sts_executable = "${sts_symlink}/STS"
	
	$sts_download_url = "${sts_url}/${sts_tarball}"
    $sts_temp_path = "/tmp/${sts_tarball}"
	
	exec { "download-sts":
		command => "/usr/bin/wget -O ${sts_temp_path} ${sts_download_url}",
		require => Package["wget"],
		creates => $sts_temp_path,
		timeout => 1200,	
	}

	file { "${sts_temp_path}" :
		require => Exec["download-sts"],
		ensure => file,
	}
	
	exec { "install-sts" :
		require => File["${sts_temp_path}"],
		cwd => $sts_install,
		command => "/bin/tar -xaz -f ${sts_temp_path}",
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
