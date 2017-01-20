# == Define: contentserver
#
# Adds an Apache configuration file.
# http://stackoverflow.com/questions/19024134/calling-puppet-defined-resource-with-multiple-parameters-multiple-times
#
class xplore::server::server() {

    $installer  = '/home/xplore/sig/server'
    $xplore_home = '/u01/app/xplore'
    $version    = '1.6'

 file { 'rngd-properties':
   ensure  => file,
   path    => '/etc/sysconfig/rngd',
   owner   => root,
   group   => root,
   content => template('xplore/rngd.erb'),
 }

 service { 'rngd':
   ensure  => running,
   enable  => true,
 }

 file { 'server-properties':
   ensure    => file,
   path      => '/home/xplore/sig/server/server.properties',
   owner     => xplore,
   group     => xplore,
   content   => template('xplore/server.properties.erb'),
 }

  exec { "xplore-installer":
    command   => "/bin/tar xvf /opt/media/Search/1.6/xPlore_1.6_linux-x64.tar",
    require   => Service["rngd"],
    cwd       => $installer,
    creates   => "${installer}/setup.bin",
    user      => xplore,
    group     => xplore,
    logoutput => true,
  }

  exec { "xplore-install":
    command     => "${installer}/setup.bin -f /home/xplore/sig/server/server.properties",
    cwd         => $installer,
    require     => [Exec["xplore-installer"],
                    Group["xplore"],
                    User["xplore"],
                    Host["xplore.local"]],
    environment => ["HOME=/home/xplore",
                    "XPLORE_HOME=${xplore_home}"],
    creates     => "${xplore_home}/installinfo/version.properties",
    user        => xplore,
    group       => xplore,
    timeout     => 1800,
    logoutput   => true,
  }
}
