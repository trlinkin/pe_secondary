class pe_secondary::console::database(
  $database = 'console',
  $username = 'console',
  $host     = 'localhost',
  $port     = '5432',
  $adapter  = 'postgresql',
  $password,
){

  file { '/etc/puppetlabs/puppet-dashboard/database.yml':
    ensure  => file,
    content => template('pe_secondary/database.yml.erb'),
  }
}
