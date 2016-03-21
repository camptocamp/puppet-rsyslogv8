# puppet-rsyslogv8 [![Build Status](https://travis-ci.org/camptocamp/puppet-rsyslogv8.svg?branch=master)](https://travis-ci.org/camptocamp/puppet-rsyslogv8)

Manage rsyslog 8.x configuration via Puppet

## Rationale

This module was made to support only a specific version of the configuration language of rsyslog, namely Rainer-Script. It simplifies the templates when compared to the most used rsyslog module in the puppet forge.

Also it allows us to have idempotency (a single puppet run will yield the final result, a second run will not change anything) even if rsyslog was not installed before the first run.


## Requirements

* Puppet >= 2.7
* puppetlabs/stdlib
* puppetlabs/apt

## Supported Plateforms

* Debian-based distributions
* RedHat-based distributions

## Usage

To install and have the global configuration of rsyslog 8.x do:
``` puppet
class { 'rsyslogv8' : }
```

However this will only give you the global configuration, no logging will be done.
The next step is to setup log actions.

To write logs to local files use:

``` puppet
class { 'rsyslogv8::config::local' : }
```

To send logs to a remote host TCP without SSL/TLS use:

``` puppet
rsyslogv8::config::ship { $remote_fqdn: }
```

To receive logs from remote host using plain TCP without SSL/TLS and write them locally use:

``` puppet
rsyslogv8::config::receive { $any_unique_name: }
```

For custom configuration file use:
``` puppet
rsyslogv8::config::snippet { $any_unique_name:
  content  => $my_config_content,
  priority => $my_config_priority,
}
```

### using SSL/TLS

You can set global SSL/TLS options like this:

``` puppet
class { 'rsyslogv8':
  ssl      => true,
  ssl_ca   => $my_ca_full_path,
  ssl_cert => $my_cert_full_path,
  ssl_key  => $my_cert_key_full_path,
}
```

This will affect all instances of `rsyslogv8::config::ship` and `rsyslogv8::config::receive`. Note that if you want to use SSL/TLS to receive logs using plain TCP you are forced to use these global options.

You can also set SSL/TLS options.

To receive logs securely:
- Using RELP:
``` puppet
class { 'rsyslogv8':
  modules_extras => {
    'imrelp' => {},
  },
}
rsyslogv8::config::receive { 'secure-logging':
  protocol                => 'relp',
  remote_auth             => 'x509/name',
  remote_authorised_peers => [ $host_fqdn_1, $host_fqdn_2, $host_fqdn_3, '*.secure-subdomain.example.com' ]
  override_ssl            => true,
  override_ssl_ca         => $my_ca_full_path,
  override_ssl_cert       => $my_cert_full_path,
  override_ssl_key        => $my_key_full_path,
}
```
- Using TCP:
``` puppet 
class { 'rsyslogv8':
  modules_extras => {
    'imtcp' => {
      'StreamDriver.AuthMode' => 'x509/name',
      'PermittedPeer' => [ $host_fqdn_1, $host_fqdn_2, $host_fqdn_3, '*.secure-subdomain.example.com' ],
    },
  },
}
rsyslogv8::config::receive { 'secure-logging':
  protocol                => 'tcp',
}
```
To ship logs securely:
- Using RELP:
``` puppet
class { 'rsyslogv8':
  modules_extras => {
    'omrelp' => {},
  },
}
rsyslogv8::config::ship { 'secure-log-server.example.com':
  protocol          => 'relp',
  remote_auth       => 'x509/name',
  override_ssl      => true,
  override_ssl_ca   => $my_ca_full_path,
  override_ssl_cert => $my_cert_full_path,
  override_ssl_key  => $my_key_full_path,
}
```
- Using TCP:
```puppet
class { 'rsyslogv8':
  modules_extras => {
    'omfwd' => {},
  },
  ssl       => true,
  ssl_ca    => $my_ca_full_path,
  ssl_cert  => $my_cert_full_path,
  ssl_key   => $my_key_full_path,
}
rsyslogv8::config::ship { 'secure-log-server.example.com':
  protocol          => 'tcp',
  remote_auth       => 'x509/name',
}
```

## Reference

### Public Classes

#### Class rsyslogv8

Basic setup and installation of rsyslog 8.x on your system.

When this class is declared with the default options, Puppet:

- Configures the official repository for rsyslogv8 of your os
- Installs rsyslogv8 with the common modules
- Places the default configuration into the [default location](#rsyslog_conf) determined by your operating system.
- Starts the rsyslog service

You can simply declare the default `rsyslogv8` class.
``` puppet
class { 'rsyslogv8': }
```

This class will not make a functional rsyslog setup, the configuration of rsyslog will not be performing any action on the logs. It will however be defining the default inputs for your operating system defining [default modules](#modules) with options.

**Parameters within `rsyslogv8`:**

#####  `rsyslog_package_name`
Name of the main rsyslog package.
Setting it to `false` will disable installation of that package.
Defaults to `rsyslog`.

#####  `relp_package_name`
Name of the relp input/output module for rsyslog package.
Setting it to `false` will disable installation of that package.
Defaults to `rsyslog-relp`.

#####  `gnutls_package_name`
Name of the gnutls module package for transport security in rsyslog.
Setting it to `false` will disable installation of that package.
Defaults to `false` on Debian 7 and ubuntu 15.04 and 15.10, defaults to `rsyslog-gnutls` for all others. 

#####  `manage_repo`
Flag to let module manage the repository for rsyslog 8.x.
Defaults to `false` for Debian 8, and `true` for all others.

#####  `repo_data`
Parameters for the OS repository type.
Default value is obviously different for each OS:

- Debian 6 and 7: Will be the parameters for apt::source
``` puppet
{
  'location' => 'http://debian.adiscon.com/v8-stable',
  'key'      => '1362E120FE08D280780169DC894ECF17AEF0CF8E',
  'release'  => "${::lsbdistcodename}/",
  'include'  => { 'source' => false },
  'repos'    => '',
  'pin'      => 1001,
}
```

- Debian 8: Defaults to an empty hash

- Ubuntu: Will be the parameters for apt::source
``` puppet
{
  'location' => 'http://ppa.launchpad.net/adiscon/v8-stable/ubuntu',
  'release'  => $::lsbdistcodename,
  'key'      => 'AB1C1EF6EDB5746803FE13E00F6DD8135234BF2B',
  'include'  => { 'source' => false },
  'repos'    => 'main',
  'pin'      => 1001,
}
```

- RedHat: Will be the parameters for yum_repo
``` puppet
{
  'baseurl'        => "http://rpms.adiscon.com/v8-stable/epel-${::operatingsystemmajrelease}/\$basearch",
  'failovermethod' => 'priority',
  'priority'       => '99',
  'enabled'        => '1',
  'gpgcheck'       => '0',
  #'gpgkey'        => '',
}
```

#####  `package_status`
The `ensure` parameter value of the packages.
Defaults to `latest`.

#####  `run_user`
The user rsyslog is run as.
Defaults to `syslog` for ubuntu, `root` on other OSes.

#####  `run_group`
The group rsyslog is runs as.
Defaults to `syslog` for ubuntu, `root` on other OSes.

#####  `spool_dir`
The spool directory rsyslog uses for working data, and queues by default.
Defaults to `/var/lib/rsyslog` on RedHat and `/var/spool/rsyslog` for other OSes.

#####  `modules`

Allows to override default OS modules and parameters. The default value of this parameters depends on the OS and version:
Defaults to:
- Centos/RHEL 7:
```
{
  'imuxsock'    => {
    'comment'   => 'provides support for local system logging',
    'arguments' => [
      { 'name'  => 'SysSock.Use',                'value' => 'off' },
      { 'name'  => 'SysSock.RateLimit.Interval', 'value' => '1'   },
      { 'name'  => 'SysSock.RateLimit.Burst',    'value' => '100' },
    ],
  },
  'imjournal' => { 'comment' => 'provides access to the systemd journal' },
}
```

- For now all others:
```
{
  'imuxsock'    => {
    'comment'   => 'provides support for local system logging',
    'arguments' => [
      { 'name'  => 'SysSock.RateLimit.Interval', 'value' => '1'   },
      { 'name'  => 'SysSock.RateLimit.Burst',    'value' => '100' },
    ],
  },
  'imklog'   => { 'comment' => 'provides kernel logging support (previously done by rklogd)' },
}
```

#####  `perm_dir`
Permissions to set on the log directory.
Defaults to `0755` on Debian and to `0750` on other OSes.

#####  `perm_file`
Permissions to set on log files.
Defaults to `0640` on Debian and to `0600` on other OSes.

#####  `umask`
Creation umask for files and directories.
Setting it to false keeps the rsyslog default value.
Defaults to `0000` on RedHat and `false` for other OSes.

#####  `service_name`
Name of the service that the module manages.
Defaults to `rsyslog`.

#####  `rsyslog_conf`
Path to the main rsyslog configuration file.
Defaults to `/etc/rsyslog.conf`

#####  `rsyslog_d`
Directory where configuration snippets are stored.
Defaults to `/etc/rsyslog.d`.

#####  `purge_rsyslog_d`
Flag to control whether the configuration snippets not managed by puppet should be removed.
Defaults to `true`.

#####  `preserve_fqdn`
Control the global rsyslog option PreserveFQDN.
Defaults to `false`.

#####  `local_host_name`
Set the local hostname as used by rsyslog in logs.
Defaults to `undef` to use the system default hostname.

#####  `max_message_size`
Control the maximum size of a syslog entry.
Defaults to `2k`.

#####  `default_template`
The default rsyslog format template to use for log entries.
Defaults to `undef` to use the default rsyslog template.

#####  `log_user`
The owner of log files created by rsyslog.
Defaults to `syslog` on ubuntu and `root` on other OSes.

#####  `log_group`
The group owner of log files created by rsyslog.
Defaults to `syslog` on ubuntu and `root`on other OSes.

#####  `ssl`
Flag to enable SSL/TLS globally in rsyslog.
Defaults to `false`.

#####  `ssl_ca`
The Default CA file to use for SSL/TLS.
Defaults to `undef`.

#####  `ssl_cert`
The Default Certificate file to use for SSL/TLS.
Defaults to `undef`.

#####  `ssl_key`
The Default Certificate Key file to use for SSL/TLS.
Defaults to `undef`.

#####  `modules_extras`
Extra modules to load on rsyslog on top of the default OS ones.
Defaults to `undef` to only load default OS modules.

#### Class rsyslogv8::config::local
Rsyslog configuration snippet that sets up local log file writing.

To set up local log file writin just use:
```
class { 'rsyslogv8::config::local': }
```
**Parameters within `rsyslogv8::config::local`:**

#### `template`
The erb file to use for the configuration file.
Defaults to `${module_name}/config/local-${::osfamily}.erb` to have an OS-dependent default file.

#### Class rsyslogv8::config::receive_templates
Define the rsyslog filename templates when receiving logs from remote host.

**Parameters within `rsyslogv8::config::receive_templates`:**

##### `base_dir`
The directory into which the logfiles will be written.

### Private Classes

#### Class rsyslogv8::params

The default OS-specific values for class `rsyslogv8`.

#### Class rsyslogv8::repository

Manage the repository configuration for rsyslogv8.

#### Class rsyslogv8::install

Installs the packages of rsyslog 8.x its modules.

#### Class rsyslogv8::config

Manage the configuration folder and main config file of rsyslog 8.x.

#### Class rsyslogv8::service

Manage the service of rsyslog 8.x.

### Public defined types

#### Defined type rsyslogv8::config::ship
Define to send locally generated logs to a remote server.

**Parameters within `rsyslogv8::config::ship`:**

##### `queue_size_limit`
Maximum number of events in the processing queue.

##### `queue_batch_size`
Maximum number of events taken from the queue at once to be processed in batch.

##### `enqueue_timeout`
Time in milisecond before dropping an event that cannot enter the processing queue because it is full.

##### `queue_mode`
Mode for the queue.
Supported Values: "LinkedList" (pure in memory, dynamic), "LinkedList-DA" (in memory, dynamic, Disk-Assisted), ...

##### `queue_filename`
The name of the queue in rsyslog.

##### `queue_max_disk_space`
Size of the maximum disk space a queue can take, if [mode](#queue_mode) is compatible.

##### `queue_save_on_shutdown`
if [mode](#queue_mode) allows it, the queue is saved to disk when rsyslog is shutdown.

##### `remote_host`
The host to which we need to connect.

##### `remote_port`
The port to use for connection, undef means default value (depends on protocol).

##### `remote_auth`
Remote authentication method to use for the connection. This is only available when global `rsyslogv8::ssl` parameter is `true` or [override_ssl](#override_ssl) is true.
Supported Values: "x509/name" (use CN or alt-names in the certificate), "anon" (no auth)

##### `remote_authorised_peers`
If [remote_auth](#remote_auth) is "x509/name" the authorised FQDN/IP that will be matched on the Certificate provided by the server, can contain wildcards.

This can be a single FQDN/IP as a string or a List of FQDN as an Array.
For TCP, only a single FQDN/IP as a string is permitted.

##### `selector`
Selector on the logs to send remotely.

##### `protocol`
Protocol used for sending, can be "tcp", "udp", "relp", ...
If an output module is needed, it must be enabled separately using either [modules](#modules) or [modules_extras](#modules_extras)

##### `override_ssl`
Should this configuration override [global ssl](#ssl) flag
Supported Values: `undef` do not override, boolean is overrided value

##### `override_ssl_ca`
Override absolute path to the CA file.
Supported Values: `undef` do not override, an absolute path to a file on the server.

Not Available for TCP.

##### `override_ssl_cert`
Override absolute path to the cert file.
Supported Values: `undef` do not override, an absolute path to a file on the server.

Not Available for TCP.

##### `override_ssl_key`
Override absolute path to the key file.
Supported Values: `undef` do not override, an absolute path to a file on the server.

Not Available for TCP.

#### Defined type rsyslogv8::config::receive
Define to receive logs from a remote server and manage them.

This type includes rsyslogv8::config::receive_templates class to define the filenames used to write the received logs.

**Parameters within `rsyslogv8::config::receive`:**

##### `queue_size_limit`
Maximum number of events in the queue.

##### `queue_batch_size`
Maximum number of events taken from the queue at once to be processed in batch.

##### `enqueue_timeout`
Time in milisecond before dropping an event that cannot enter the processing queue because it is full.

##### `queue_mode`
Mode for the queue.
Supported Values: "LinkedList" (pure in memory, dynamic), "LinkedList-DA" (in memory, dynamic, Disk-Assisted), ...

##### `queue_filename`
The name of the queue in rsyslog.

##### `queue_max_disk_space`
Size of the maximum disk space a queue can take, if [mode](#queue_mode) is compatible.

##### `queue_save_on_shutdown`
if [mode](#queue_mode) allows it, the queue is saved to disk when rsyslog is shutdown.

##### `protocol`
Protocol used for receiving events.
Supported Values: "tcp", "udp", "relp".
If an output module is needed, it must be enabled separately using either [modules](#modules) or [modules_extras](#modules_extras)

##### `remote_auth`
Remote authentication method to use for the connection. This is only available when global `rsyslogv8::ssl` parameter is `true` or [override_ssl](#override_ssl) is true.
Supported Values: "x509/name" (use CN or alt-names in the certificate), "anon" (no auth)

##### `remote_authorised_peers`
If [remote_auth](#remote_auth) is "x509/name" the list of FQDN/IP that will be matched on the Certificate provided by the client, can contain wildcards.

##### `ruleset_name`
Name of the (user-defined) ruleset to use for the input, if `undef` a ruleset will be created to write files locally.
Default Value is `undef`

##### `override_ssl`
Should this configuration override [global ssl](#ssl) flag
Note that you cannot override ssl options for the plain TCP [protocol](#protocol) and need to set the parameters for the [module](#modules_extras)
Supported Values: `undef` do not override, boolean is overrided value

##### `override_ssl_ca`
Override absolute path to the CA file.
Supported Values: `undef` do not override, an absolute path to a file on the server.

##### `override_ssl_cert`
Override absolute path to the cert file.
Supported Values: `undef` do not override, an absolute path to a file on the server.

##### `override_ssl_key`
Override absolute path to the key file.
Supported Values: `undef` do not override, an absolute path to a file on the server.

##### `port`
Port number to use for listening, `undef` for default port.

#### Defined type rsyslogv8::config::snippet
Raw configuration snippet type.

**Parameters within `rsyslogv8::config::snippet`:**

##### `content`
The content of the configuration file.

##### `priority`
The two digit (in a String) priority of the file, lower means it will be loaded earlier by rsyslog.
