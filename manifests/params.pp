# OS Specific Defaults for ::rsyslogv8 can be overriden as class parameter.
# Definition structure is as follows:
# - Global value (name also used as parameter name in ::rsyslogv8)
# - OS Family value (Global name prepended by "_family_") override global default
# - OS Specific value (Family name prepended by "_os") override family default
# - OS Version Specific value (OS Specific name prepended by "_version") override os specific value
# defined in reverse order in the file
class rsyslogv8::params {

  case $::osfamily {
    'debian': {
      $_family_manage_repo          = undef
      $_family_repo_data            = undef
      $_family_relp_package_name    = undef
      $_family_rsyslog_package_name = undef
      $_family_gnutls_package_name  = undef
      $_family_kafka_package_name   = undef
      $_family_run_user             = undef
      $_family_run_group            = undef
      $_family_spool_dir            = undef
      $_family_modules              = undef
      $_family_perm_dir             = '0755'
      $_family_perm_file            = '0640'
      $_family_umask                = undef
      $_family_log_user             = undef
      $_family_log_group            = undef
      $_family_pin_packages         = undef
      $_family_defaults_file        = '/etc/default/rsyslog'
      case $::operatingsystem {
        'Debian': {
          $_os_family_manage_repo          = true
          $_os_family_repo_data            = {
            'location' => 'http://debian.adiscon.com/v8-stable',
            'key'      => '1362E120FE08D280780169DC894ECF17AEF0CF8E',
            'release'  => "${::lsbdistcodename}/",
            'include'  => { 'source' => false },
            'repos'    => '',
            'pin'      => 1001,
          }
          $_os_family_relp_package_name    = undef
          $_os_family_rsyslog_package_name = undef
          $_os_family_gnutls_package_name  = undef
          $_os_family_kafka_package_name   = undef
          $_os_family_run_user             = undef
          $_os_family_run_group            = undef
          $_os_family_spool_dir            = undef
          $_os_family_modules              = undef
          $_os_family_perm_dir             = undef
          $_os_family_perm_file            = undef
          $_os_family_umask                = undef
          $_os_family_log_user             = undef
          $_os_family_log_group            = undef
          $_os_family_pin_packages         = undef

          case $::operatingsystemmajrelease {
            '6': {
              $_version_os_family_manage_repo          = undef
              $_version_os_family_repo_data            = undef
              $_version_os_family_relp_package_name    = undef
              $_version_os_family_rsyslog_package_name = undef
              $_version_os_family_gnutls_package_name  = undef
              $_version_os_family_kafka_package_name   = false
              $_version_os_family_run_user             = undef
              $_version_os_family_run_group            = undef
              $_version_os_family_spool_dir            = undef
              $_version_os_family_modules              = undef
              $_version_os_family_perm_file            = undef
              $_version_os_family_perm_dir             = undef
              $_version_os_family_umask                = undef
              $_version_os_family_pin_packages         = undef
            }
            '7': {
              $_version_os_family_manage_repo          = undef
              $_version_os_family_repo_data            = undef
              $_version_os_family_relp_package_name    = undef
              $_version_os_family_rsyslog_package_name = undef
              $_version_os_family_gnutls_package_name  = false
              $_version_os_family_kafka_package_name   = false
              $_version_os_family_run_user             = undef
              $_version_os_family_run_group            = undef
              $_version_os_family_spool_dir            = undef
              $_version_os_family_modules              = undef
              $_version_os_family_perm_file            = undef
              $_version_os_family_perm_dir             = undef
              $_version_os_family_umask                = undef
              $_version_os_family_pin_packages         = undef
            }
            '8': {
              $_version_os_family_manage_repo          = undef
              $_version_os_family_repo_data            = {
                'location' => 'http://ftp.debian.org/debian',
                #'key'      => '',
                'release'  => 'jessie-backports',
                'include'  => { 'source' => false },
                'repos'    => 'main',
              }
              $_version_os_family_relp_package_name    = undef
              $_version_os_family_rsyslog_package_name = undef
              $_version_os_family_gnutls_package_name  = undef
              $_version_os_family_kafka_package_name   = undef
              $_version_os_family_run_user             = undef
              $_version_os_family_run_group            = undef
              $_version_os_family_spool_dir            = undef
              $_version_os_family_modules              = undef
              $_version_os_family_perm_file            = undef
              $_version_os_family_perm_dir             = undef
              $_version_os_family_umask                = undef
              $_version_os_family_pin_packages         = {
                priority => 1001,
                packages => [
                  'liblognorm2',
                  'rsyslog',
                  'rsyslog-gnutls',
                  'rsyslog-relp',
                  'librelp0',
                  'rsyslog-mysql',
                  'rsyslog-pgsql',
                  'rsyslog-mongodb',
                  'rsyslog-doc',
                  'rsyslog-gssapi',
                ],
                release  => 'jessie-backports',
              }
            }
            default: {
              fail("Unsupported operatingsystemmajrelease (${::operatingsystem}) ${::operatingsystemmajrelease}")
            }
          }
        }
        'Ubuntu': {
          $_os_family_manage_repo          = true
          $_os_family_repo_data            = {
            'location' => 'http://ppa.launchpad.net/adiscon/v8-stable/ubuntu',
            'release'  => $::lsbdistcodename,
            'key'      => 'AB1C1EF6EDB5746803FE13E00F6DD8135234BF2B',
            'include'  => { 'source' => false },
            'repos'    => 'main',
            'pin'      => 1001,
          }
          $_os_family_relp_package_name    = undef
          $_os_family_rsyslog_package_name = undef
          $_os_family_gnutls_package_name  = undef
          $_os_family_kafka_package_name   = false
          $_os_family_run_user             = 'syslog'
          $_os_family_run_group            = 'syslog'
          $_os_family_spool_dir            = undef
          $_os_family_modules              = undef
          $_os_family_perm_dir             = undef
          $_os_family_perm_file            = undef
          $_os_family_umask                = undef
          $_os_family_log_user             = 'syslog'
          $_os_family_log_group            = 'syslog'
          $_os_family_pin_packages         = undef

          case $::operatingsystemmajrelease {
            '14.04': {
              $_version_os_family_manage_repo          = undef
              $_version_os_family_repo_data            = undef
              $_version_os_family_relp_package_name    = undef
              $_version_os_family_rsyslog_package_name = undef
              $_version_os_family_gnutls_package_name  = undef
              $_version_os_family_kafka_package_name   = undef
              $_version_os_family_run_user             = undef
              $_version_os_family_run_group            = undef
              $_version_os_family_spool_dir            = undef
              $_version_os_family_modules              = undef
              $_version_os_family_perm_file            = undef
              $_version_os_family_perm_dir             = undef
              $_version_os_family_umask                = undef
              $_version_os_family_pin_packages         = undef
            }
            '15.04', '15.10': {
              $_version_os_family_manage_repo          = undef
              $_version_os_family_repo_data            = undef
              $_version_os_family_relp_package_name    = undef
              $_version_os_family_rsyslog_package_name = undef
              $_version_os_family_gnutls_package_name  = false
              $_version_os_family_kafka_package_name   = undef
              $_version_os_family_run_user             = undef
              $_version_os_family_run_group            = undef
              $_version_os_family_spool_dir            = undef
              $_version_os_family_modules              = undef
              $_version_os_family_perm_file            = undef
              $_version_os_family_perm_dir             = undef
              $_version_os_family_umask                = undef
              $_version_os_family_pin_packages         = undef
            }
            '16.04': {
              $_version_os_family_manage_repo          = false
              $_version_os_family_repo_data            = {}
              $_version_os_family_relp_package_name    = undef
              $_version_os_family_rsyslog_package_name = undef
              $_version_os_family_gnutls_package_name  = undef
              $_version_os_family_kafka_package_name   = undef
              $_version_os_family_run_user             = undef
              $_version_os_family_run_group            = undef
              $_version_os_family_spool_dir            = undef
              $_version_os_family_modules              = undef
              $_version_os_family_perm_file            = undef
              $_version_os_family_perm_dir             = undef
              $_version_os_family_umask                = undef
              $_version_os_family_pin_packages         = undef
            }
            default: {
              fail("Unsupported operatingsystemmajrelease (${::operatingsystem}) ${::operatingsystemmajrelease}")
            }
          }
        }
        default: {
          fail("Unsupported operatingsystem ${::operatingsystem}")
        }
      }
    }
    'redhat': {
      $_family_manage_repo          = undef
      $_family_repo_data            = undef
      $_family_relp_package_name    = undef
      $_family_rsyslog_package_name = undef
      $_family_gnutls_package_name  = undef
      $_family_kafka_package_name   = undef
      $_family_run_user             = undef
      $_family_run_group            = undef
      $_family_spool_dir            = '/var/lib/rsyslog'
      $_family_modules              = undef
      $_family_perm_dir             = undef
      $_family_perm_file            = undef
      $_family_umask                = '0000'
      $_family_log_user             = undef
      $_family_log_group            = undef
      $_family_pin_packages         = undef
      $_family_defaults_file        = '/etc/sysconfig/rsyslog'

      case $::operatingsystem {
        'Redhat', 'CentOS': {
          $_os_family_manage_repo          = true
          $_os_family_repo_data            = {
            'baseurl'        => "http://rpms.adiscon.com/v8-stable/epel-${::operatingsystemmajrelease}/\$basearch",
            'failovermethod' => 'priority',
            'priority'       => '99',
            'enabled'        => '1',
            'gpgcheck'       => '0',
            #'gpgkey'        => '',
          }
          $_os_family_relp_package_name    = undef
          $_os_family_rsyslog_package_name = undef
          $_os_family_gnutls_package_name  = undef
          $_os_family_kafka_package_name   = undef
          $_os_family_run_user             = undef
          $_os_family_run_group            = undef
          $_os_family_spool_dir            = undef
          $_os_family_modules              = undef
          $_os_family_perm_dir             = undef
          $_os_family_perm_file            = undef
          $_os_family_umask                = undef
          $_os_family_log_user             = undef
          $_os_family_log_group            = undef
          $_os_family_pin_packages         = undef

          case $::operatingsystemmajrelease {
            '5': {
              $_version_os_family_manage_repo          = undef
              $_version_os_family_repo_data            = undef
              $_version_os_family_relp_package_name    = undef
              $_version_os_family_rsyslog_package_name = undef
              $_version_os_family_gnutls_package_name  = undef
              $_version_os_family_kafka_package_name   = false
              $_version_os_family_run_user             = undef
              $_version_os_family_run_group            = undef
              $_version_os_family_spool_dir            = undef
              $_version_os_family_modules              = undef
              $_version_os_family_perm_file            = undef
              $_version_os_family_perm_dir             = undef
              $_version_os_family_umask                = undef
              $_version_os_family_pin_packages         = undef
            }
            '6': {
              $_version_os_family_manage_repo          = undef
              $_version_os_family_repo_data            = undef
              $_version_os_family_relp_package_name    = undef
              $_version_os_family_rsyslog_package_name = undef
              $_version_os_family_gnutls_package_name  = undef
              $_version_os_family_kafka_package_name   = undef
              $_version_os_family_run_user             = undef
              $_version_os_family_run_group            = undef
              $_version_os_family_spool_dir            = undef
              $_version_os_family_modules              = undef
              $_version_os_family_perm_file            = undef
              $_version_os_family_perm_dir             = undef
              $_version_os_family_umask                = undef
              $_version_os_family_pin_packages         = undef
            }
            '7': {
              $_version_os_family_manage_repo          = undef
              $_version_os_family_repo_data            = undef
              $_version_os_family_relp_package_name    = undef
              $_version_os_family_rsyslog_package_name = undef
              $_version_os_family_gnutls_package_name  = undef
              $_version_os_family_kafka_package_name   = undef
              $_version_os_family_run_user             = undef
              $_version_os_family_run_group            = undef
              $_version_os_family_spool_dir            = undef
              $_version_os_family_modules              = {
                                        'imuxsock'  => {
                                          'comment'   => 'provides support for local system logging',
                                          'arguments' => {
                                            'SysSock.Use'                => false,
                                            'SysSock.RateLimit.Interval' => 0,
                                          },
                                        },
                                        'imjournal' => {
                                          'comment'   => 'provides access to the systemd journal',
                                          'arguments' => {
                                            'StateFile'            => '/var/lib/rsyslog/imjournal.state',
                                            'PersistStateInterval' => '100',
                                          },
                                        },
              }
              $_version_os_family_perm_file            = undef
              $_version_os_family_perm_dir             = undef
              $_version_os_family_umask                = undef
              $_version_os_family_pin_packages         = undef
            }
            default: {
              fail("Unsupported operatingsystemmajrelease (${::operatingsystem}) ${::operatingsystemmajrelease}")
            }
          }
        }
        default: {
          fail("Unsupported operatingsystem ${::operatingsystem}")
        }
      }
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }

  $manage_repo                    = pick(
                                      $::rsyslogv8::params::_version_os_family_manage_repo,
                                      $::rsyslogv8::params::_os_family_manage_repo,
                                      $::rsyslogv8::params::_family_manage_repo,
                                      false
                                    )
  $repo_data                      = pick(
                                      $::rsyslogv8::params::_version_os_family_repo_data,
                                      $::rsyslogv8::params::_os_family_repo_data,
                                      $::rsyslogv8::params::_family_repo_data,
                                      {}
                                    )
  $rsyslog_package_name           = pick(
                                      $::rsyslogv8::params::_version_os_family_rsyslog_package_name,
                                      $::rsyslogv8::params::_os_family_rsyslog_package_name,
                                      $::rsyslogv8::params::_family_rsyslog_package_name,
                                      'rsyslog'
                                    )
  $gnutls_package_name            = pick(
                                      $::rsyslogv8::params::_version_os_family_gnutls_package_name,
                                      $::rsyslogv8::params::_os_family_gnutls_package_name,
                                      $::rsyslogv8::params::_family_gnutls_package_name,
                                      'rsyslog-gnutls'
                                    )
  $kafka_package_name             = pick(
                                      $::rsyslogv8::params::_version_os_family_kafka_package_name,
                                      $::rsyslogv8::params::_os_family_kafka_package_name,
                                      $::rsyslogv8::params::_family_kafka_package_name,
                                      'rsyslog-kafka'
                                    )
  $relp_package_name              = pick(
                                      $::rsyslogv8::params::_version_os_family_relp_package_name,
                                      $::rsyslogv8::params::_os_family_relp_package_name,
                                      $::rsyslogv8::params::_family_relp_package_name,
                                      'rsyslog-relp'
                                    )
  $run_user                       = pick(
                                      $::rsyslogv8::params::_version_os_family_run_user,
                                      $::rsyslogv8::params::_os_family_run_user,
                                      $::rsyslogv8::params::_family_run_user,
                                      'root'
                                    )
  $run_group                      = pick(
                                      $::rsyslogv8::params::_version_os_family_run_group,
                                      $::rsyslogv8::params::_os_family_run_group,
                                      $::rsyslogv8::params::_family_run_group,
                                      'root'
                                    )
  $spool_dir                      = pick(
                                      $::rsyslogv8::params::_version_os_family_spool_dir,
                                      $::rsyslogv8::params::_os_family_spool_dir,
                                      $::rsyslogv8::params::_family_spool_dir,
                                      '/var/spool/rsyslog'
                                    )
  $modules                        = pick(
                                      $::rsyslogv8::params::_version_os_family_modules,
                                      $::rsyslogv8::params::_os_family_modules,
                                      $::rsyslogv8::params::_family_modules,
                                      {
                                        'imuxsock' => {
                                          'comment'   => 'provides support for local system logging',
                                          'arguments' => {
                                            'SysSock.RateLimit.Interval' => 0,
                                            'SysSock.Name'               => '/dev/log',
                                          },
                                        },
                                        'imklog'   => { 'comment' => 'provides kernel logging support (previously done by rklogd)' },
                                      }
                                    )
  $perm_dir                       = pick(
                                      $::rsyslogv8::params::_version_os_family_perm_dir,
                                      $::rsyslogv8::params::_os_family_perm_dir,
                                      $::rsyslogv8::params::_family_perm_dir,
                                      '0750'
                                    )
  $perm_file                      = pick(
                                      $::rsyslogv8::params::_version_os_family_perm_file,
                                      $::rsyslogv8::params::_os_family_perm_file,
                                      $::rsyslogv8::params::_family_perm_file,
                                      '0600'
                                    )
  $umask                          = pick(
                                      $::rsyslogv8::params::_version_os_family_umask,
                                      $::rsyslogv8::params::_os_family_umask,
                                      $::rsyslogv8::params::_family_umask,
                                      false
                                    )
  $package_status                 = 'latest'
  $service_name                   = 'rsyslog'
  $rsyslog_conf                   = '/etc/rsyslog.conf'
  $rsyslog_d                      = '/etc/rsyslog.d'
  $purge_rsyslog_d                = true
  $preserve_fqdn                  = false
  $local_host_name                = undef
  $max_message_size               = '2k'
  $default_template               = undef
  $log_user                       = pick(
                                      $::rsyslogv8::params::_os_family_log_user,
                                      $::rsyslogv8::params::_family_log_user,
                                      'root'
                                    )
  $log_group                      = pick(
                                      $::rsyslogv8::params::_os_family_log_group,
                                      $::rsyslogv8::params::_family_log_group,
                                      'root'
                                    )

  $pin_packages                   = pick(
                                      $::rsyslogv8::params::_version_os_family_pin_packages,
                                      $::rsyslogv8::params::_os_family_pin_packages,
                                      $::rsyslogv8::params::_family_pin_packages,
                                      false
                                    )
  $defaults_file                   = pick(
                                      $::rsyslogv8::params::_family_defaults_file,
                                      undef
                                    )
}
