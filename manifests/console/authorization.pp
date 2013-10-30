class pe_secondary::console::authorization (
  $console_cn           = 'pe-internal-dashboard',
  $additional_acl_allow = [],
){

  $acl_allow = flatten( [$console_cn,$additional_acl_allow] )

  file_line { 'puppetdb_whitelist':
    ensure => present,
    line   => $console_cn,
    path   => '/etc/puppetlabs/puppetdb/certificate-whitelist',
  }

  auth_conf::acl { '/certificate_status':
    allow      => $acl_allow,
    auth       => 'yes',
    acl_method => ['find','search','save','destroy'],
  }

  auth_conf::acl { '/resource_type':
    allow      => $acl_allow,
    auth       => 'yes',
    acl_method => ['find','search'],
  }

  auth_conf::acl { '/facts':
    allow      => $acl_allow,
    auth       => 'any',
    acl_method => ['find','search'],
  }
}

