# Define unicorn::instance
#
# This defines creates an unicorn instance and let you manage
# its service and configuration
#
define unicorn::instance (
  $approot,
  $config_template          = 'unicorn/unicorn.conf.erb',
  $config_ru_template       = 'unicorn/config.ru.erb',
  $config_ru_rails_template = 'unicorn/config.ru.rails.erb',
  $init_template            = 'unicorn/service.init.erb',
  $worker_processes         = '4',
  $socket_path              = false,
  $socket_backlog           = '64',
  $port                     = false,
  $tcp_nopush               = true,
  $timeout_secs             = '60',
  $preload_app              = true,
  $rails                    = false,
  $rails_app                = undef,
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
  $noops                    = undef,
  $ensure                   = 'present',
  $working_directory        = undef,
  $stderr_path              = undef,
  $stdout_path              = undef,
  $pid_path                 = undef,
  $config_path              = undef,
  $config_ru_path           = undef,
  $monitor                  = params_lookup('monitor', 'global'),
  $monitor_tool             = params_lookup('monitor_tool', 'global'),
  $monitor_target           = params_lookup('monitor_target', 'global'),
  $monitor_config_hash      = params_lookup('monitor_config_hash'),
  $firewall                 = params_lookup('firewall', 'global'),
  $firewall_tool            = params_lookup('firewall_tool', 'global'),
  $firewall_src             = params_lookup('firewall_src', 'global'),
  $firewall_dst             = params_lookup('firewall_dst', 'global'),
  $manage_service           = true
) {

  require unicorn

  $bool_monitor = any2bool($monitor)
  $bool_firewall = any2bool($firewall)
  $bool_manage_service = any2bool($manage_service)

  if $ensure != 'present' {
    $manage_monitor = false
  } else {
    $manage_monitor = true
  }

  if $ensure != 'present' {
    $manage_firewall = false
  } else {
    $manage_firewall = true
  }

  $manage_service_autorestart = $service_autorestart ? {
    true    => Service["unicorn_${name}"],
    false   => undef,
  }

  $real_command = $rails ? {
    true  => "${command}_rails",
    false => $command
  }

  $real_working_directory = $working_directory ? {
    undef   => "${approot}/current",
    default => $working_directory,
  }

  $real_stderr_path = $stderr_path ?{
    undef   => "${approot}/log/unicorn.stderr.log",
    default => $stderr_path,
  }

  $real_stdout_path = $stdout_path ?{
    undef   => "${approot}/log/unicorn.stdout.log",
    default => $stdout_path,
  }

  $real_pid_path = $pid_path ? {
    undef   => "${approot}/pids/unicorn.pid",
    default => $pid_path,
  }

  $real_config_path = $config_path ? {
    ''      => "${approot}/config/unicorn.conf.rb",
    default => $config_path,
  }

  $real_config_ru_path = $config_ru_path ? {
    ''      => "${approot}/config.ru",
    default => $config_ru_path,
  }

  $real_config_ru_template = $rails ? {
    true    => $config_ru_rails_template,
    false   => $config_ru_template,
  }

  if ($rails == true) and ($rails_app == undef) {
    fail('unicorn: Must specify a rails_app for config.ru when using rails')
  }

  file { "${name}_unicorn.conf":
    ensure  => $ensure,
    path    => $real_config_path,
    mode    => 644,
    owner   => $owner,
    group   => $group,
    content => template($config_template),
    notify  => $manage_service_autorestart,
    noop    => $noops,
  }


  file { "${name}_config.ru":
    ensure  => $ensure,
    path    => $real_config_ru_path,
    mode    => 644,
    owner   => $owner,
    group   => $group,
    content => template($real_config_ru_template),
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

  if $ensure == 'present' and $bool_manage_service == true {
    service { "unicorn_${name}":
      ensure     => running,
      enable     => true,
      noop       => $noops,
    }
  }

  ### Service monitoring, if enabled ( monitor => true )
  if $bool_monitor == true and $port != false {
    monitor::port { "unicorn_${name}_${protocol}_${port}":
      protocol => $protocol,
      port     => $port,
      target   => $monitor_target,
      tool     => $monitor_tool,
      enable   => $manage_monitor,
    }
    monitor::process { "unicorn_${name}_process":
      process     => $process,
      service     => $service,
      pidfile     => $pid_file,
      user        => $process_user,
      argument    => $process_args,
      tool        => $monitor_tool,
      enable      => $manage_monitor,
      config_hash => $monitor_config_hash,
    }
  }


  ### Firewall management, if enabled ( firewall => true )
  if $bool_firewall == true and $port != false {
    firewall { "logstash_${protocol}_${port}":
      source      => $firewall_src,
      destination => $firewall_dst,
      protocol    => $protocol,
      port        => $port,
      action      => 'allow',
      direction   => 'input',
      tool        => $firewall_tool,
      enable      => $manage_firewall,
    }
  }
}
