# = Class: unicorn
#
# This is the main unicorn class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, unicorn class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $unicorn_myclass
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $unicorn_absent
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: undef
#
# Default class params - As defined in unicorn::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*package*]
#   The name of unicorn package
#
# == Examples
#
# You can use this class in 2 ways:
# - Set variables (at top scope level on in a ENC) and "include unicorn"
# - Call unicorn as a parametrized class
#
# See README for details.
#
#
class unicorn (
  $my_class            = params_lookup( 'my_class' ),
  $version             = params_lookup( 'version' ),
  $absent              = params_lookup( 'absent' ),
  $noops               = params_lookup( 'noops' ),
  $package             = params_lookup( 'package' )
  ) inherits unicorn::params {

  $bool_absent=any2bool($absent)

  ### Definition of some variables used in the module
  $manage_package = $unicorn::bool_absent ? {
    true  => 'absent',
    false => $unicorn::version,
  }

  ### Managed resources
  if ! defined(Package[$unicorn::package]) {
    package { $unicorn::package:
      ensure   => $unicorn::manage_package,
      provider => 'gem',
      noop     => $unicorn::noops,
    }
  }

  ### Include custom class if $my_class is set
  if $unicorn::my_class {
    include $unicorn::my_class
  }

}
