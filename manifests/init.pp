# == Class: fail2ban
#
class fail2ban (
  Enum['absent', 'latest', 'present', 'purged'] $package_ensure = 'present',
  String[1]                                     $package_name,
  Optional[Array[String]]                       $package_list,

  Stdlib::Absolutepath       $config_dir,
  Stdlib::Absolutepath       $config_filter_dir
  Boolean                    $config_dir_purge         = false,
  Boolean                    $config_dir_recurse       = true,

  String[1]                  $config_file_user,
  String[1]                  $config_file_group,
  String[1]                  $config_file_mode,

  Optional[String[1]]        $config_file_source       = undef,
  Optional[String[1]]        $config_file_string       = undef,
  Optional[String[1]]        $config_file_template     = undef,

  Hash[String[1], Any]       $config_file_hash         = {},

  Enum['running', 'stopped'] $service_ensure           = 'running',
  String[1]                  $service_name,
  Boolean                    $service_enable           = true,

  String[1]                  $action                   = 'action_mb',
  Integer[0]                 $bantime                  = 432000,
  String[1]                  $email                    = "fail2ban@${::domain}",
  String[1]                  $sender                   = "fail2ban@${::fqdn}",
  String[1]                  $iptables_chain           = 'INPUT',
  Array[String[1]]           $jails                    = ['ssh', 'ssh-ddos'],
  Integer[0]                 $maxretry                 = 3,
  Array                      $whitelist                = ['127.0.0.1/8'],
  Hash[String, Hash]         $custom_jails             = {},
  String[1]                  $banaction                = 'iptables-multiport',
) inherits ::fail2ban::params {
  $config_file_content = default_content($config_file_string, $config_file_template)

  if $config_file_hash {
    create_resources('fail2ban::define', $config_file_hash)
  }

  if $package_ensure == 'absent' {
    $config_dir_ensure  = 'directory'
    $config_file_ensure = 'present'
    $_service_ensure    = 'stopped'
    $_service_enable    = false
  } elsif $package_ensure == 'purged' {
    $config_dir_ensure  = 'absent'
    $config_file_ensure = 'absent'
    $_service_ensure    = 'stopped'
    $_service_enable    = false
  } else {
    $config_dir_ensure  = 'directory'
    $config_file_ensure = 'present'
    $_service_ensure    = $service_ensure
    $_service_enable    = $service_enable
  }

  anchor { 'fail2ban::begin': }
  -> class { '::fail2ban::install': }
  -> class { '::fail2ban::config': }
  ~> class { '::fail2ban::service': }
  -> anchor { 'fail2ban::end': }
}
