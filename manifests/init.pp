class pe_secondary_master (
  $primary_cname,
  $change_filebucket      = true,
  $add_puppetdb_whitelist = true,
){

  augeas { 'puppet.conf_ca':
    context => '/files/etc/puppetlabs/puppet/puppet.conf'
    changes => [
      'set master/ca false',
      "set agent/ca_server ${primary_cname}",
      ],
  }

  file_line { 'pe-httpd_revocation':
    ensure => present,
    match  => '    SSLCARevocationFile     /etc/puppetlabs/puppet/ssl/ca/ca_crl.pem',
    line   => '    SSLCARevocationFile     /etc/puppetlabs/puppet/ssl/crl.pem',
    path   => '/etc/puppetlabs/httpd/conf.d/puppetmaster.conf',
  }

  if $change_filebucket {
    file_line { 'seondary_filebucket':
      ensure => present,
      line   => "  server => '${primary_cname}',",
      match  => '^\s*server\s*=>',
      path   => '/etc/puppetlabs/puppet/manifests/site.pp',
    }
  }

  if $add_puppetdb_whitelist {
    file_line { 'puppetdb_whitelist_master':
      ensure => present,
      line   => $clientcert,
      path   => '/etc/puppetlabs/puppetdb/certificate-whitelist',
    }
  }
}
