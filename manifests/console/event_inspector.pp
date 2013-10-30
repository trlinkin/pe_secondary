class pe_secondary::console::event_inspector(
  $console_name = $::fqdn,
){

  file_line { 'event_inspector_ca_file':
    ensure => present,
    line   => "    ca_file: /opt/puppet/share/puppet-dashboard/certs/pe-internal-dashboard-${console_name}.ca_cert.pem",
    match  => '^\s*ca_file:',
    path   => '/opt/puppet/share/event-inspector/config/config.yml',
  }

  file_line { 'event_inspector_cert_file':
    ensure => present,
    line   => "    cert: /opt/puppet/share/puppet-dashboard/certs/pe-internal-dashboard-${console_name}.cert.pem",
    match  => '^\s*cert:',
    path   => '/opt/puppet/share/event-inspector/config/config.yml',
  }

  file_line { 'event_inspector_key_file':
    ensure => present,
    line   => "    key: /opt/puppet/share/puppet-dashboard/certs/pe-internal-dashboard-${console_name}.private_key.pem",
    match  => '^\s*key:',
    path   => '/opt/puppet/share/event-inspector/config/config.yml',
  }
}

