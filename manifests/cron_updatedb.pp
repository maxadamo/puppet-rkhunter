# @summary
#   Manage the cron job for rkhunter DB update
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
class rkhunter::cron_updatedb (
  Enum['present', 'absent'] $ensure           = 'present',
  Variant[String[1, 2], Integer[0, 23]] $hour = 2,  # we demand further validation to cron resource
  Variant[String[1], Integer[0, 7]] $weekday  = '1',  # we demand further validation to cron resource
  Stdlib::Email $email                        = 'root@localhost',
  Variant[Stdlib::Httpurl, Stdlib::Httpsurl, Undef] $http_proxy = undef,
) {
  $cron_cmd = join(['/usr/local/bin/rkhunter-update-email.sh', $email, $http_proxy], ' ')

  file { '/usr/local/bin/rkhunter-update-email.sh':
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0754',
    source => 'puppet:///modules/rkhunter/mail-notification/rkhunter-update-email.sh',
  }

  cron { 'rkhunter-cron-update':
    ensure  => 'present',
    command => $cron_cmd,
    user    => 'root',
    hour    => $hour,
    minute  => fqdn_rand(59),
    weekday => $weekday,
  }
}
