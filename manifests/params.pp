# Class: unicorn::params
#
# This class defines default parameters used by the main module class unicorn
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to unicorn class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class unicorn::params {

  ### Application related parameters

  $package = $::operatingsystem ? {
    default => 'unicorn',
  }

  # General Settings
  $my_class = ''
  $version = 'present'
  $absent = false
  $noops = false

}
