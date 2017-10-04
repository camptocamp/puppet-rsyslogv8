define rsyslogv8::config::imfile(
  $files         = [ $title ],
  $ruleset_name  = 'RSYSLOG_DefaultRuleset',
  $rsyslog_tag   = $title,
  $facility      = 'local0',
  $severity      = 'notice',
  $readmode      = 'line',
) {
  if ! is_array($files) {
    fail('files must be an array of file full-paths')
  }
  validate_absolute_path($files)

  # create config snippet using template
  ::rsyslogv8::config::snippet { "imfile-${title}":
    content  => template("${module_name}/config/imfile.erb"),
    priority => '20',
  }
}
