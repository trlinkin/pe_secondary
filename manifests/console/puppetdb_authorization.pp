class pe_secondary::console::puppetdb_authorization (
  $console_cn = "pe-internal-dashboard-${::pe_secondary::params::console_name}",
){

  @@file_line { 'puppetdb_whitelist':
    ensure => present,
    line   => $console_cn,
    path   => '/etc/puppetlabs/puppetdb/certificate-whitelist',
    tag    => ['puppetdb_whitelist']
  }

}

