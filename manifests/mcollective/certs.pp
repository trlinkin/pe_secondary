class pe_secondary::mcollective::certs (
  $primary_node_name,
){

  # If the master we're contacting is the primary, then we want its mcollective certs
  # this allows us to bootstrap new masters off a primary
  if $::servername == $primary_node_name {

    # Private Keys
    file { 'pe_internal_broker':
      ensure  => file,
      path    => '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-broker.pem',
      content => file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-broker.pem'),
    }

      file { 'pe_internal_mcollective_servers':
      ensure  => file,
      path    => '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-mcollective-servers.pem',
      content => file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-mcollective-servers.pem'),
    }

    file { 'pe-internal-peadmin-mcollective-client':
      ensure  => file,
      path    => '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-peadmin-mcollective-client.pem',
      content => file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-peadmin-mcollective-client.pem'),
    }

    file { 'pe-internal-puppet-console-mcollective-client':
      ensure  => file,
      path    => '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-puppet-console-mcollective-client.pem',
      content => file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-puppet-console-mcollective-client.pem'),
    }


    # Public Keys
    file { 'pe_internal_broker-public':
      ensure  => file,
      path    => '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-broker.pem',
      content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-broker.pem'),
    }

    file { 'pe_internal_mcollective_servers-public':
      ensure  => file,
      path    => '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-mcollective-servers.pem',
      content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-mcollective-servers.pem'),
    }

    file { 'pe_internal_peadmin_mcollective_client-public':
      ensure  => file,
      path    => '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-peadmin-mcollective-client.pem',
      content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-peadmin-mcollective-client.pem'),
    }

    file { 'pe_internal_puppet_console_mcollective_client-public':
      ensure  => file,
      path    => '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-puppet-console-mcollective-client.pem',
      content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-puppet-console-mcollective-client.pem'),
    }
  }
}
