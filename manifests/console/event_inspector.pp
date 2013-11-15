class pe_secondary::console::event_inspector(
  $console_name  = $::pe_secondary::params::console_name,
  $puppetdb_port = $::pe_secondary::params::puppetdb_port,
  $puppetdb_host = $::fqdn,
){

  file { 'pe_event_inspector_config':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('pe_secondary/event_inspector_config.yml.erb'),
  }
}

