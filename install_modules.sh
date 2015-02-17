#! /bin/bash
puppet module install puppetlabs/stdlib #--force --modulepath '/vagrant/puppet/modules'
puppet module install paulosuzart-gvm #--force --modulepath '/vagrant/puppet/modules'
puppet module install saz-vim #--force --modulepath '/vagrant/puppet/modules'
puppet module install maestrodev-rvm
puppet module install puppetlabs-apt
