class pe_secondary::console::authorization (
  $console_cn = "pe-internal-dashboard-${::pe_secondary::params::console_name}",
){

  @@file_line { 'puppetdb_whitelist':
    ensure => present,
    line   => $console_cn,
    path   => '/etc/puppetlabs/puppetdb/certificate-whitelist',
    tags   => ['puppetdb_whitelist']
  }

}

