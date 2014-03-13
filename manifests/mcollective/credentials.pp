##
## This is terribly ugly.  The credentials file is already being managed
## by the built-in pe_mcollective::ca module as a file resource.
##
class pe_secondary::mcollective::credentials {

  $credentials      = strip(file('/etc/puppetlabs/mcollective/credentials'))
  $credentials_file = '/etc/puppetlabs/mcollective/credentials'

  exec { 'mco-credentials':
    command   => "echo \"${credentials}\" > ${credentials_file}",
    unless    => "grep -qw \"${credentials}\" ${credentials_file}",
    path      => [ '/bin' ],
    logoutput => true,
  }

}
