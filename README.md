# Puppet module: unicorn

This is a Puppet module for unicorn
It provides only package installation and management

Based on Example42 layouts by Alessandro Franceschi / Lab42

Inspired by the following Unicorn modules:

https://github.com/viniciusteles/puppet-unicorn

https://github.com/ssvarma/puppetlabs_unicorn/

https://github.com/deck/puppet-unicorn


Official site: http://www.example42.com

Official git repository: http://github.com/example42/puppet-unicorn

Released under the terms of Apache 2 License.

This module requires the presence of Example42 Puppi module in your modulepath.


## USAGE - Basic management

* Install unicorn with default settings

        class { 'unicorn': }

* Install a specific version of unicorn package

        class { 'unicorn':
          version => '1.0.1',
        }

* Remove unicorn resources

        class { 'unicorn':
          absent => true
        }

* Module dry-run: Do not make any change on *all* the resources provided by the module

        class { 'unicorn':
          noops => true
        }

* Automatically include a custom subclass

        class { 'unicorn':
          my_class => 'example42::my_unicorn',
        }


## TESTING
[![Build Status](https://travis-ci.org/example42/puppet-unicorn.png?branch=master)](https://travis-ci.org/example42/puppet-unicorn)
