class rvm_wrapper {

  include rvm
  $jruby_version = hiera('version::jruby')

  rvm_system_ruby {$jruby_version:
    ensure => 'present',
    default_use => true,
    build_opts => ['--verify-downloads', '2', '--max-time', '20'],
    require => Class['rvm'];
  }
}