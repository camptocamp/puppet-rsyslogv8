class rsyslogv8::install {

  if $rsyslogv8::rsyslog_package_name != false {
    package { $rsyslogv8::rsyslog_package_name:
      ensure  => $rsyslogv8::package_status,
      notify  => Class['rsyslogv8::service'],
      require => Class['rsyslogv8::repository'],
    }
  }

  if $rsyslogv8::relp_package_name != false {
    package { $rsyslogv8::relp_package_name:
      ensure  => $rsyslogv8::package_status,
      notify  => Class['rsyslogv8::service'],
      require => [Class['rsyslogv8::repository'], Package[$rsyslogv8::rsyslog_package_name]],
    }
  }

  if $rsyslogv8::gnutls_package_name != false {
    package { $rsyslogv8::gnutls_package_name:
      ensure  => $rsyslogv8::package_status,
      notify  => Class['rsyslogv8::service'],
      require => [Class['rsyslogv8::repository'], Package[$rsyslogv8::rsyslog_package_name]],
    }
  }

  if $rsyslogv8::kafka_package_name != false {
    package { $rsyslogv8::kafka_package_name:
      ensure  => $rsyslogv8::package_status,
      notify  => Class['rsyslogv8::service'],
      require => [Class['rsyslogv8::repository'], Package[$rsyslogv8::rsyslog_package_name]],
    }
  }

}
