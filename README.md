# Mid-Scale Puppet Enterprise Scaled/HA Stack #
###A guide and a module###
##Synopsis##
The following is a rough guide for deploying a medium-scale Puppet Enterprise installation.  This will be comprised of one "*primary master*", and additional "*secondary masters*".  In this particular scenario, the *primary master* is comprised of all components of the PE stack in an "active" configuration.  Any *secondary masters* will have the full PE stack, but will utilize the *primary master* for active CA and PostgreSQL responsibilities.

Some pre-installation steps are assumed.  Generic DNS names should be set up to direct traffic to the appropriate component.  Some ideas for this are:

`puppet.example.com` Points to a load balancer that directs traffic to the Puppet masters (`8140`).
`master.example.com` Points to the *current live* primary master with active CA and PostgreSQL responsibilities.

##Terminology##

###primary_cname###
Refers to the DNS name that points to the primary Puppet master (full stack).

*e.g. `master.example.com`*

###Primary Puppetmaster###
The Puppet Master that currently serves all the non-sharable roles, including the CA server and the PostgreSQL server.  All active services on each additional master that need CA or database access will do so by accessing the primary through the primary_cname.  There can only be one primary master per cluster.

###Secondary Puppetmaster###
Any Puppet Master that is not currently hosting the non-sharable services in an *active* manner.  You can have as many secondary masters as you desire.

###general_cname###
A generic DNS record that points to all the active Puppet Masters in an HA group.  This can be used to send requests to any master in an HA group.

*e.g. `puppet.example.com`*

##Classes##

###pe_secondary###
* Disables CA functionality on the node
* Corrects the CRL (revocation file) path for pe-httpd
* Optional: Sets the filebucket to the primary master (default)
* Optional: Exports the puppetdb whitelist (default)

**Parameters**

`primary_cname`

Required. Should be set to the `primary_cname` as defined above.

`change_filebucket`

Default: true. Set the filebucket to the `primary_cname` or not.

`export_puppetdb_whitelist`

Default: true. Export the `$clientcert` to be added to the PuppetDB whitelist.


###pe_secondary::console###
* Configures the console as a non-CA server
* Handles console-related certificates
* Updates the event inspector config's certificate names

**Parameters**

`ca_server`

Required.  The address for the CA server.  Should likely be set to the `primary_cname`, as defined above.



###pe_secondary::console::database###
* Updates the console's database config to point to the primary master

**Parameters**

`host`

The address for the PostgreSQL host. Should likely be set to the `primary_cname`, as defined above.

`password`

The database password, as retrieved from the Primary Puppetmaster.


###pe_secondary::mcollective###
* Provides the secondary master(s) with the Mcollective certificates from the primary
* Provides the secondary master(s) with the Mcollective credentials from the primary

###pe_secondary::puppetdb###
* Adds the certificates to the puppetdb whitelist

##Typical Configuration##

###1. Install PE###
On two different nodes, install the full PE Master stack.  This includes every role available in the installer, with the exception of the "Cloud Provisioner".

**Certificate Names**: It's important to choose a certificate name appropriate for each master.  You must also provide a common, shared name for `dns_alt_names`, such as "`puppet.example.com`" that any master can be reached at.  Additionally, you should add the `primary_cname` here so that any secondary master could assume the role of the primary in the event of failure.

###2. On the Primary###
1. Install this module.
2. Modify the `postgres_listen_addresses` parameter for the `pe_puppetdb` class on the primary master.  Set the value to `*` to have the PostgreSQL server listen on every interface.

Modify `/etc/puppetlabs/puppet/autosign.conf` and add the certificate name for the secondary's console.  It will look like: `pe-internal-dashboard-<secondary fqdn>`

Run a `puppet agent -t` on the primary master to ensure the PostgreSQL listen address gets updated and the service restarted.


###3. On the Secondary###
Let's temporarily disable the Puppet agent while we prepare the secondary: `service pe-puppet stop`

Re-create certificates and run against the primary master.

1. `rm -rf /etc/puppetlabs/puppet/ssl`
2. `puppet agent -t --server <primary server>`
3. On the primary: sign the certificate request on the primary with the `allow-dns-alt-names` option
4. On the secondary: run against the primary again: `puppet agent -t --server <primary server>`

###4. On the Primary's Console###
Classify the secondary with the following classes:

1. `pe_puppetdb`: Modify the `postgres_listen_addresses` parameter and set it to `*` (NOTE: On Puppet Enterprise 3.2.x, this class is now called `pe_puppetdb::pe`)
2. `pe_secondary`: Modify the `primary_cname` parameter and set it to the current live CA server
3. `pe_secondary::console`: Modify the `ca_server` parameter to point to the current live CA server
4. `pe_secondary::mcollective`: Modify the `primary_node_name` parameter and set it to the primary master by name.
5. `pe_puppetdb::master` (NOTE: On Puppet Enterprise 3.2.x, this class is now called `pe_puppetdb::pe::master`)

###5. Database configuration###
You'll need to gather database information from the primary for the secondary to use.

**For the console**

1. On the primary master: `grep password /etc/puppetlabs/puppet-dashboard/database.yml`
2. On the primary console: Add the `pe_secondary::console::database` class to the secondary and modify the `host` parameter to point to the `primary_cname` and the `password` parameter to the password recorded in the previous step.

**For PuppetDB**

1. On the primary master: `grep password /etc/puppetlabs/puppetdb/conf.d/database.ini`
2. On the primary console: Modify the `pe_puppetdb` parameters and set the `database_host` to the `primary_cname` and the `database_password` to the password recorded in the previous step.

###6. Do a Puppet run on the secondary###
On the secondary, run Puppet against the primary:

`puppet agent -t --server <primary server>`

If you see errors, try re-running against the primary.  If errors persist, re-evaluate the previous steps.  Also, make sure there's no pending certificate signing requests on the primary master by doing a `puppet cert list` and signing as needed.

###7. Re-initialize the PuppetDB Certificates###
When you installed the PE stack on the secondary, certificates were generated that need to be re-created.

The following steps need to be done on the secondary.

1. Remove the PuppetDB certificates: `rm -rf /etc/puppetlabs/puppetdb/ssl`
2. Generate new certificates: `/opt/puppet/sbin/puppetdb-ssl-setup`
3. Restart the PuppetDB service: `service pe-puppetdb restart`

###8. Console Authentication###
The console on the secondary needs to be configured to use the PostgreSQL database on the primary master.

**On the primary master**

1. Modify `/etc/puppetlabs/console-auth/database.yml` and ensure the `host:` value is set to the `primary_cname`
2. Record the database password

**On the secondary master**

1. Modify `/etc/puppetlabs/console-auth/database.yml` and set the `password` value to the value recorded from the primary master.
2. Set the value for `host` to the `primary_cname`

###9. Add the secondary to console groups###

On the primary's console, add the secondary to the following groups:

1. puppet_master
2. puppet_console

Edit the `puppet_master` group and add a variable called `activemq_brokers`.  Set the value to a comma-separated list of the FQDNs for the Puppet masters.

Edit the `mcollective` console group and add a variable called `fact_stomp_server`.  Set the value to a comma-separated list of the FQDNs for the Puppet masters, as you did in the previous step.

###10. Reactivate the secondary###
Perform a Puppet run against the primary:
`puppet agent -t --server <primary server>`

Restart PE services:

```
service pe-httpd restart
service pe-puppetdb restart
service pe-puppet restart
service pe-memcached restart
service pe-puppet-dashboard-workers restart
```

###11. Validate the secondary's functionality###
At this point, the secondary should be ready to start serving catalogs to agents.

Ensure the secondary can run cleanly against itself:

`puppet agent -t`

##Failover and Recovery##

In the event of primary master failure, a secondary can assume the roles of the primary.  Unfortunately, this is no automatic at this time.

The roles the secondary will need to assume are the CA and PostgreSQL server.

###Certificate Authority###
The `/etc/puppetlabs/puppet/ssl/ca` directory should be backed up reguarily.  To transfer CA responsibilities, this directory needs to be placed on a new master.

Set `ca=true` in `/etc/puppetlabs/puppet/puppet.conf` and restart the `pe-httpd` service.

###Databases###
Backing up the PostgreSQL databases can be done in a variety of ways, such as "log shipping" or "log streaming".

The database credentials should also be backed up.

###DNS###
Once the CA and PostgreSQL services have been assumed on a new (or existing) master, the `primary_cname` should be changed to point to the new server.
