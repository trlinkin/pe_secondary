class pe_secondary::console::puppetdb_authorization (
  $console_cn = "pe-internal-dashboard-${::pe_secondary::params::console_name}",
) inherits pe_secondary::params {

  @@file_line { "puppetdb_whitelist_${fqdn}":
    ensure => present,
    line   => $console_cn,
    path   => '/etc/puppetlabs/puppetdb/certificate-whitelist',
    tag    => ['puppetdb_whitelist']
  }

}

