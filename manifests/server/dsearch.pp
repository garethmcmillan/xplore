# == Define: search
#
# Adds an Apache configuration file.
# http://stackoverflow.com/questions/19024134/calling-puppet-defined-resource-with-multiple-parameters-multiple-times
#
class xplore::server::dsearch() {
  $installer       = '/u01/app/xplore/setup/dsearch'
  $xplore_home     = '/u01/app/xplore'
# note this should only be the first two ports, eg if 9300, use 93
  $xplore_port     = '93'
  $xplore_data     = '/u01/app/xplore/data'
  $xplore_config   = '/u01/app/xplore/config'
  $xplore_host     = 'xplore.local'
  $xplore_password = '1234qwer'
  $xplore_admin    = 'admin'
  $service_name    = 'PrimaryDsearch'

  # template(<FILE REFERENCE>, [<ADDITIONAL FILES>, ...])
  file { 'dsearch-response':
    ensure    => file,
    path      => '/home/xplore/sig/dsearch/dsearch.properties',
    owner     => root,
    group     => root,
    content   => template('xplore/dsearch.properties.erb'),
  }

  file { 'dsearch-serviceConfig':
    ensure    => file,
    path      => "/etc/default/${service_name}.conf",
    owner     => root,
    group     => root,
    mode      => 755,
    content   => template('xplore/service.conf.erb'),
  }

  file { 'dsearch-serviceStartScript':
    ensure    => file,
    path      => "/etc/init.d/${service_name}",
    owner     => root,
    group     => root,
    mode      => 755,
    content   => template('xplore/service.erb'),
  }

  exec {'chkconfig-dsearch':
    require     => [File["dsearch-serviceConfig"],
                    File["dsearch-serviceStartScript"],
                  ],
    command  => "/sbin/chkconfig --add ${service_name}; /sbin/chkconfig ${service_name} on",
    #onlyif   => ["! /sbin/service ${service_name} status"],
  }


  exec { "dsearch-create":
    command     => "${installer}/dsearchConfig.bin LAX_VM ${xplore_home}/java64/1.8.0_77/jre/bin/java -f /home/xplore/sig/dsearch/dsearch.properties -r /home/xplore/sig/dsearch/response.properties",
    cwd         => $installer,
    require     => [File["dsearch-response"],
                    User["xplore"],
                    ],
    environment => ["HOME=/home/xplore",
                    ],
    creates     => "${xplore_home}/wildfly9.0.1/server/startPrimaryDsearch.sh",
    user        => xplore,
    group       => xplore,
    logoutput   => true,
    timeout     => 3000,
  }

  service { $service_name:
    ensure  => running,
    enable  => true,
    require => [Exec["chkconfig-dsearch"],
                Exec["dsearch-create"],
                File["dsearch-serviceConfig"],
                File["dsearch-serviceStartScript"],]
  }

}
