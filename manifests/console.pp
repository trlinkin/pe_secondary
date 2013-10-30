class pe_secondary::console(
  $certname = $::fqdn,
  $ca_server,
){

  file { '/opt/puppet/share/puppet-dashboard/certs':
    ensure => directory,
    purge  => true,
  }

  file_line { 'console_ca_server':
    ensure => present,
    line   => "ca_server: '${ca_server}'",
    match  => 'ca_server:',
    path   => '/etc/puppetlabs/puppet-dashboard/settings.yml',
  }

  file_line { 'console_cn_name':
    ensure => present,
    line   => "cn_name: 'pe-internal-dashboard-${certname}'",
    match  => 'cn_name:',
    path   => '/etc/puppetlabs/puppet-dashboard/settings.yml',
  }

  file_line { 'console_ca_certificate_path':
    ensure => present,
    line   => "ca_certificate_path: 'certs/pe-internal-dashboard-${certname}.ca_cert.pem'",
    match  => '^\s*ca_certificate_path:',
    path   => '/etc/puppetlabs/puppet-dashboard/settings.yml',
  }

  file { "/opt/puppet/share/puppet-dashboard/certs/pe-internal-dashboard-${certname}.ca_cert.pem": }

  file_line { 'console_ca_crl_path':
    ensure => present,
    line   => "ca_crl_path: 'certs/pe-internal-dashboard-${certname}.ca_crl.pem'",
    match  => 'ca_crl_path:',
    path   => '/etc/puppetlabs/puppet-dashboard/settings.yml',
  }

  file { "/opt/puppet/share/puppet-dashboard/certs/pe-internal-dashboard-${certname}.ca_crl.pem": }

  file_line { 'console_certificate_path':
    ensure => present,
    line   => "certificate_path: 'certs/pe-internal-dashboard-${certname}.cert.pem'",
    match  => '^\s*certificate_path:',
    path   => '/etc/puppetlabs/puppet-dashboard/settings.yml',
  }

  file { "/opt/puppet/share/puppet-dashboard/certs/pe-internal-dashboard-${certname}.cert.pem": }

  file_line { 'console_private_key_path':
    ensure => present,
    line   => "private_key_path: 'certs/pe-internal-dashboard-${certname}.private_key.pem'",
    match  => 'private_key_path:',
    path   => '/etc/puppetlabs/puppet-dashboard/settings.yml',
  }

  file { "/opt/puppet/share/puppet-dashboard/certs/pe-internal-dashboard-${certname}.private_key.pem": }

  file_line { 'console_public_key_path':
    ensure => present,
    line   => "public_key_path: 'certs/pe-internal-dashboard-${certname}.public_key.pem'",
    match  => 'public_key_path:',
    path   => '/etc/puppetlabs/puppet-dashboard/settings.yml',
  }

  file { "/opt/puppet/share/puppet-dashboard/certs/pe-internal-dashboard-${certname}.public_key.pem": }

  exec { 'create_console_keys':
    command => '/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production cert:create_key_pair',
    creates => "/opt/puppet/share/puppet-dashboard/certs/pe-internal-dashboard-${certname}.public_key.pem",
    require => [ File_line['console_private_key_path', 'console_public_key_path', 'console_ca_server' ]],
  }

  exec { 'request_console_certs':
    command => '/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production cert:request',
    creates => "/opt/puppet/share/puppet-dashboard/certs/pe-internal-dashboard-${certname}.ca_cert.pem",
    require => Exec['create_console_keys'],
  }

  exec { 'retrieve_console_certs':
    command => '/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production cert:retrieve',
    creates => "/opt/puppet/share/puppet-dashboard/certs/pe-internal-dashboard-${certname}.cert.pem",
    require => Exec['request_console_certs'],
  }

  if defined('request_manager') {
    Class['pe_secondary::console'] ~> Service['pe-httpd']
  }

}

