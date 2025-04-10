# @summary
#   Manage the cron job for rkhunter
#
# @param ensure
#   Ensure cron job and script are present or absent
#
# @param hour
#   Hour to run the cron job
#
# @param weekday
#   Weekday to run the cron job
#
# @param email
#   Email address to send cron job output
#
# @param log_output
#   Log output file for cron job. It will be passed as an argument to
#   rkhunter-email.sh script. If you set it to Undef, the script will
#   send stdout to email as well.
#
class rkhunter::cron (
  Enum['present', 'absent'] $ensure                = 'present',
  Variant[String[1, 2], Integer[0, 23]] $hour      = 4,  # we demand further validation to cron resource
  Variant[String[1], Integer[0, 7]] $weekday       = '*',  # we demand further validation to cron resource
  Stdlib::Email $email                             = 'root@localhost',
  Variant[Stdlib::Absolutepath, Undef] $log_output = '/var/log/rkhunter_warnings.log',
) {
  $cron_cmd = join(['/usr/local/bin/rkhunter-email.sh', $email, $log_output], ' ')

  file { '/usr/local/bin/rkhunter-email.sh':
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0754',
    source => 'puppet:///modules/rkhunter/mail-notification/rkhunter-email.sh',
  }

  cron { 'rkhunter-cron':
    ensure  => $ensure,
    command => $cron_cmd,
    user    => 'root',
    hour    => $hour,
    minute  => fqdn_rand(59),
    weekday => $weekday,
  }
}
