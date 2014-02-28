class pe_secondary::mcollective (
  $primary_node_name
) {

  class { 'pe_secondary::mcollective::certs':
    primary_node_name => $primary_node_name,
  }

  class { 'pe_secondary::mcollective::credentials': }

}
