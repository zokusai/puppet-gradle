# == Class: gradle
#
# Install the Gradle build system from the official project site.
# The required Java runtime environment will not be installed automatically.
#
# Supported operating systems are:
#   - Fedora Linux
#   - Debian Linux
#   - Ubuntu Linux
#
# === Parameters
#
# [*version*]
#   Specify the version of Gradle which should be installed.
#
# [*base_url*]
#   Specify the base URL of the Gradle ZIP archive. Usually this doesn't
#   need to be changed.
#
# [*url*]
#   Specify the absolute URL of the Gradle ZIP archive. This overrides any
#   version which has been set before.
#
# [*target*]
#   Specify the location of the symlink to the Gradle installation on the local
#   filesystem.
#
# [*daemon*]
#   Specify if the Gradle daemon should be running
#
# === Variables
#
# The variables being used by this module are named exactly like the class
# parameters with the prefix 'gradle_', e. g. *gradle_version* and *gradle_url*.
#
# === Examples
#
#  class { 'gradle':
#    version => '1.8'
#  }
#
# === Authors
#
# Jochen Schalanda <j.schalanda@gini.net>
#
# === Copyright
#
# Copyright 2012, 2013 smarchive GmbH, 2013 Gini GmbH
#--
# TODO: Retrieve lastest version info from https://services.gradle.org/versions/current
#--
class gradle(
  $version      = '2.11',
  $dist         = 'all',
  $base_url     = 'https://services.gradle.org/distributions',
  $url          = undef,
  $download_dir = '/tmp',
  $target       = '/opt',
  $timeout      = 300,
  $daemon       = true,
  $proxy        = undef,
  $user         = undef,
  $group        = undef,
) {

  $gradle_basename = "gradle-${version}"
  $gradle_home     = "${target}/gradle"

  $url_real = pick($url , "${base_url}/${gradle_basename}-${dist}.zip")

  Exec {
    path  => [
      '/usr/local/sbin', '/usr/local/bin',
      '/usr/sbin', '/usr/bin', '/sbin', '/bin',
    ],
    user  => $user,
    group => $group,
  }

  archive { "${gradle_basename}-${dist}.zip":
    ensure     => present,
    url        => $url_real,
    checksum   => false,
    src_target => $download_dir,
    target     => $target,
    root_dir   => $gradle_basename,
    extension  => 'zip',
    timeout    => $timeout,
    proxy      => $proxy,
  }

  file { $gradle_home:
    ensure  => link,
    target  => "${target}/${gradle_basename}/${gradle_basename}",
    require => Archive["${gradle_basename}-${dist}.zip"],
  }

  file { '/etc/profile.d/gradle.sh':
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/gradle.sh.erb"),
  }
}
