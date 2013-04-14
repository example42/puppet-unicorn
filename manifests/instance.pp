# Define unicorn::instance
#
# This defines creates an unicorn instance and let you manage
# its service and configuration
#
define unicorn::instance (
  $approot,
  $config_template          = 'unicorn/unicorn.conf.erb',
  $config_ru_template       = 'unicorn/config.ru.erb',
  $init_template            = 'unicorn/service.init.erb',
  $worker_processes         = '4',
  $socket_path              = false,
  $socket_backlog           = '64',
  $port                     = false,
  $tcp_nopush               = true,
  $timeout_secs             = '60',
  $preload_app              = true,
  $rails                    = false,
  $rolling_restarts         = true,
  $rolling_restarts_sleep   = '1',
  $debug_base_port          = false,
  $require_extras           = [],
  $before_exec              = [],
  $before_fork_extras       = [],
  $after_fork_extras        = [],
  $command                  = 'unicorn',
  $env                      = 'production',
  $owner                    = 'root',
  $group                    = 'root',
  $service_autorestart      = true,
  $noops                    = false,
  $ensure                   = 'present'
) {

  $manage_service_autorestart = $service_autorestart ? {
    true    => Service["unicorn_${name}"],
    false   => undef,
  }

  $real_command = $rails ? {
    true  => "${command}_rails",
    false => $command
  }

  file { "${name}_unicorn.conf":
    ensure  => $ensure,
    path    => "${approot}/config/unicorn.conf.rb",
    mode    => 644,
    owner   => $owner,
    group   => $group,
    content => template($config_template),
    notify  => $manage_service_autorestart,
    noop    => $noops,
  }


  file { "${name}_config.ru":
    ensure  => $ensure,
    path    => "${approot}/config.ru",
    mode    => 644,
    owner   => $owner,
    group   => $group,
    content => template($config_ru_template),
    notify  => $manage_service_autorestart,
    noop    => $noops,
  }

  file { "${name}_unicorn.init":
    ensure  => $ensure,
    path    => "/etc/init.d/unicorn_${name}",
    mode    => '0755',
    owner   => root,
    group   => root,
    content => template($init_template),
    notify  => $manage_service_autorestart,
    noop    => $noops,
  }

  if $ensure == 'present' {
    service { "unicorn_${name}":
      ensure     => running,
      enable     => true,
      noop       => $noops,
    }
  }
}
