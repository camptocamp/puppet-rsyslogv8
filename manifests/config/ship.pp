# Define to send locally generated logs to a remote server.
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
) {
  # Input checkint
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
  if $override_ssl_ca != false and ! is_string($override_ssl_ca) and is_absolute_path($override_ssl_ca) {
    fail('parameter override_ssl_ca must be an aboslute path or false')
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

  if $override_ssl != undef {
    $_ssl = $override_ssl
  } else {
    $_ssl = $rsyslogv8::ssl
  }

  if $override_ssl_ca != false {
    $_real_ca = $override_ssl_ca
  } else {
    $_real_ca = $::rsyslogv8::ssl_ca
  }

  if $override_ssl_key != false {
    $_real_key = $override_ssl_key
  } else {
    $_real_key = $::rsyslogv8::ssl_key
  }

  if $override_ssl_cert != false {
    $_real_cert = $override_ssl_cert
  } else {
    $_real_cert = $::rsyslogv8::ssl_cert
  }

  case $remote_auth {
    'anon': {
    }
    'x509/name': {
      if ! ( $_ssl ) {
        fail('::rsyslogv8::ssl or override_ssl must be enabled to authenticate using x509/name')
      }
    }
    default: {
      fail("unknown value '${remote_auth}' for parameter remote_auth")
    }
  }

  case $protocol {
    'tcp': {
      if $override_ssl != undef or $override_ssl_cert or $override_ssl_key or $override_ssl_ca {
        fail('cannot override ssl parameters for plain tcp connection consider using relp if you really want this feature')
      }
      if $_ssl {
        $__ssl_extra_options_enable = "StreamDriver=\"gtls\"\n"
      } else {
        $__ssl_extra_options_enable = "StreamDriver=\"ptcp\"\n"
      }
      $_omodule = 'omfwd'
      $_omodule_extra_opts = " Protocol=\"tcp\""
      $_remote_auth_real_option_name = 'StreamDriverAuthMode'
      $_remote_authorised_peers_real_option_name = 'StreamDriverPermittedPeers'
      $_ssl_extra_options = $__ssl_extra_options_enable
      $_remote_auth_real_mode = $remote_auth
      if is_array($remote_authorised_peers) {
        fail('in tcp, remote_authorised_peers must be a string for a single FQDN/IP')
      }
    }

    'relp': {
      $_omodule = 'omrelp'
      $_omodule_extra_opts = undef
      $_remote_auth_real_option_name = 'tls.authMode'
      $_remote_authorised_peers_real_option_name = 'tls.permittedpeer'
      $__ssl_extra_options_ca   = " tls.caCert=\"${_real_ca}\"\n"
      if $_real_key {
        $__ssl_extra_options_key  = " tls.myPrivKey=\"${_real_key}\"\n"
      } else {
        $__ssl_extra_options_key = undef
      }
      if $_real_cert {
        $__ssl_extra_options_cert = " tls.myCert=\"${_real_cert}\"\n"
      } else {
        $__ssl_extra_options_cert = undef
      }
      case $remote_auth {
        'anon': {
          $_remote_auth_real_mode = undef
        }
        'x509/name': {
          $_remote_auth_real_mode = 'name'
        }
        default: {
          fail('do not know what to do with remote_auth value, please fix it')
        }
      }
      if $_ssl {
        $__ssl_extra_options_enable = "tls=\"on\"\n"
      } else {
        $__ssl_extra_options_enable = "tls=\"off\"\n"
      }
      $_ssl_extra_options = "${__ssl_extra_options_enable}${__ssl_extra_options_ca}${__ssl_extra_options_key}${__ssl_extra_options_cert}"
    }

    'udp': {
      if $_ssl {
        fail('cannot use ssl for udp connection consider using relp or tcp for this feature')
      }
      $_omodule = 'omfwd'
      $_ssl_extra_options = undef
      $_omodule_extra_opts =  " Protocol=\"udp\""
      if $remote_auth != 'anon' {
        fail('cannot authenticate hosts in udp consider using relp or tcp for this feature')
      }
      $_remote_auth_real_option_name = undef
      $_remote_auth_real_mode = $remote_auth
    }
    default: {
      fail("unsupported protocol '${protocol}'")
    }
  }

  # create config snippet using template
  ::rsyslogv8::config::snippet { "ship-${title}":
    content  => template("${module_name}/config/ship.erb"),
    priority => 90,
  }
}
