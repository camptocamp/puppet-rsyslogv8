# Define to send locally generated logs to a remote server.
# This action will be put in the ruleset named "RSYSLOG_DefaultRuleset"
#  remote_auth: [Enum] remote authentication method. Supported Values: "x509/name" (if ssl enabled use CN), "anon" (no auth)
#  queue_size_limit: [Integer|undef] Maximum number of events in the queue
#  queue_batch_size: [Integer] Maximum number of events taken from the queue at once to be processed in batch
#  enqueue_timeout: [Integer] (ms) before dropping waiting incoming events
#  queue_mode: [Enum] Mode for the queue. Supported Values: "LinkedList" (pure in memory, dynamic), "LinkedList-DA" (in memory, dynamic, Disk-Assisted), ...
#  queue_filename: [String] The name of the queue in rsyslog
#  queue_max_disk_space: [String] Size of the maximum disk space a queue can take, if mode is compatible
#  queue_save_on_shutdown: [Boolean] if queue_mode allows it, the queue is saved to disk when rsyslog is shutdown
#  remote_host: [FQDN|IP] the host to which we need to connect
#  remote_port: [Integer|IP] the port to use for connection, undef means default value (depends on protocol)
#  remote_authorised_peers: [FQDN|IP|undef|List[FQDN|IP]] if remote_auth is "x509/name" this is a list of/single FQDN/IP that will match, can contain wildcards if null, remote_host is used.
#  selector: [String] selector on the logs to send remotely
#  protocol: [Enum] protocol used for sending, can be "tcp", "udp", "relp", ... if an output module is needed, it must be enabled separately
#  override_ssl: [Boolean|undef] should this configuration override global ssl flag (undef do not override, boolean is overrided value) NOT avaiable for TCP connections
#  override_ssl_ca: [String] override absolute path to the CA file, NOT avaiable for tcp
#  override_ssl_cert: [String] override absolute path to the cert file, NOT avaiable for tcp
#  override_ssl_key: [String] override absolute path to the key file, NOT avaiable for tcp
#  action_resume_retry_cnt: [Integer] number of retries when action fails, default 0, -1 means infinite
define rsyslogv8::config::ship (
  $remote_host             = $title,
  $remote_port             = undef,
  $remote_auth             = 'anon',
  $queue_size_limit        = undef,
  $queue_batch_size        = 16,
  $enqueue_timeout         = 2000,
  $queue_mode              = 'LinkedList-DA',
  $queue_filename          = "queue-ship-${title}",
  $queue_max_disk_space    = '2g',
  $queue_save_on_shutdown  = true,
  $remote_authorised_peers = undef,
  $selector                = '*.*',
  $protocol                = 'tcp',
  $override_ssl            = undef,
  $override_ssl_ca         = false,
  $override_ssl_cert       = false,
  $override_ssl_key        = false,
  $action_resume_retry_cnt = undef,
  $template                = undef,
) {
  # Input checking
  if ! is_string($remote_host) and ! ( is_domain_name($remote_host) or is_ip_address($remote_host) ){
    fail('parameter remote_host must be a hostname/fqdn or an ip address')
  }
  if $remote_port != undef and ! is_integer($remote_port) {
    fail('parameter remote_port must be an integer or undef')
  }
  if ! is_string($remote_auth) {
    fail('parameter remote_auth must be a string')
  }
  if $queue_size_limit != undef and ! is_integer($queue_size_limit) {
    fail('parameter queue_size_limit must be an integer or undef')
  }
  if $queue_batch_size != undef and ! is_integer($queue_batch_size) {
    fail('parameter queue_batch_size must be an integer or undef')
  }
  if ! is_integer($enqueue_timeout) {
    fail('parameter enqueue_timeout must be an integer or undef')
  }
  if ! is_string($queue_mode) {
    fail('parameter queue_mode must be a string')
  }
  if ! is_string($queue_max_disk_space) {
    fail('parameter queue_max_disk_space must be a string')
  }
  if ! is_bool($queue_save_on_shutdown) {
    fail('parameter queue_save_on_shutdown must be a boolean')
  }
  if ! is_string($queue_filename) {
    fail('parameter queue_filename must be a string')
  }
  if $remote_authorised_peers != undef and ! is_string($remote_authorised_peers) and ! is_array($remote_authorised_peers) {
    fail('parameter remote_authorised_peers must be a FQDN/IP, an array of FQDN/IP or undef')
  }
  if ! is_string($selector) {
    fail('parameter selector must be a string')
  }
  if ! is_string($protocol) {
    fail('parameter protocol must be a string')
  }
  if $override_ssl != undef and ! is_bool($override_ssl) {
    fail('parameter override_ssl must be a boolean or undef')
  }
  $_remote_authorised_peers = pick($remote_authorised_peers, $remote_host)
  if $override_ssl_ca != false {
    validate_absolute_path($override_ssl_ca)
  }
  if $override_ssl_cert != false {
    validate_absolute_path($override_ssl_cert)
  }
  if $override_ssl_key != false {
    validate_absolute_path($override_ssl_key)
  }

  # Local variables definitions for template and semantic checking of input
  case $queue_mode {
    'LinkedList-DA': {
      $_queue_mode = 'LinkedList'
      $_queue_disk = true
    }
    'LinkedList': {
      $_queue_mode = 'LinkedList'
      $_queue_disk = false
    }
    'Disk': {
      $_queue_mode = 'Disk'
      $_queue_disk = true
    }
    'FixedArray': {
      $_queue_mode = 'FixedArray'
      $_queue_disk = false
    }
    'FixedArray-DA': {
      $_queue_mode = 'FixedArray'
      $_queue_disk = true
    }
    default: {
      fail("unknown value '${queue_mode}' for parameter queue_mode")
    }
  }

  case $protocol {
    'tcp': {
      if $override_ssl != undef or $override_ssl_cert or $override_ssl_key or $override_ssl_ca {
        fail('cannot override ssl parameters for plain tcp connection consider using relp if you really want this feature')
      }
      if $override_ssl or ( $override_ssl == undef and $::rsyslogv8::ssl ) {
        if $::osfamily == 'RedHat' and ( $::operatingsystemmajrelease == '5' or $::operatingsystemmajrelease == '6') {
          notice("TLS with relp might not work in ${::operatingsystem}${::operatingsystemmajrelease} due to an old version of gnutls")
        }
      }
      $_omodule = 'omfwd'
      if is_array($remote_authorised_peers) {
        fail('in tcp, remote_authorised_peers must be a string for a single FQDN/IP')
      }
    }

    'relp': {
      $_omodule = 'omrelp'
      if $override_ssl or ( $override_ssl == undef and $::rsyslogv8::ssl ) {
        if $::osfamily == 'RedHat' and ( $::operatingsystemmajrelease == '5' or $::operatingsystemmajrelease == '6' ) {
          fail("TLS with relp does NOT work in ${::operatingsystem}${::operatingsystemmajrelease} due to an old version of gnutls")
        }
      }
    }

    'udp': {
      $_omodule = 'omfwd'
      if $remote_auth != 'anon' {
        fail('cannot authenticate hosts in udp consider using relp or tcp for this feature')
      }
    }
    default: {
      fail("unsupported protocol '${protocol}'")
    }
  }

  # create config snippet using template
  ::rsyslogv8::config::snippet { "ship-${title}":
    content  => template("${module_name}/config/ship.erb"),
    priority => '90',
  }
}
