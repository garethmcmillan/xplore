# == Define: search
#
# Adds an Apache configuration file.
# http://stackoverflow.com/questions/19024134/calling-puppet-defined-resource-with-multiple-parameters-multiple-times
#
define xplore::server::dsearch(
  $installer_location,
  $xplore_home,
  $xplore_owner,
  $xplore_group,
  $xplore_data,
  $xplore_config,

  $dsearch_service = $name,
  $dsearch_host,
# note this should only be the first two ports, eg if 9300, use 93
  $dsearch_port,
  $dsearch_admin,
  $dsearch_password,

  $service_name = $dsearch_service,
) {
  # template(<FILE REFERENCE>, [<ADDITIONAL FILES>, ...])
  file { 'dsearch-response':
    ensure    => file,
    path      => "${installer_location}/dsearch/dsearch.properties",
    owner     => root,
    group     => root,
    content   => template('xplore/dsearch.properties.erb'),
  }

  file { 'dsearch-serviceConfig':
    ensure    => file,
    path      => "/etc/default/${dsearch_service}.conf",
    owner     => root,
    group     => root,
    mode      => 755,
    content   => template('xplore/service.conf.erb'),
  }

  file { 'dsearch-serviceStartScript':
    ensure    => file,
    path      => "/etc/init.d/${dsearch_service}",
    owner     => root,
    group     => root,
    mode      => 755,
    content   => template('xplore/service.erb'),
  }

  exec {'chkconfig-dsearch':
    require     => [File["dsearch-serviceConfig"],
                    File["dsearch-serviceStartScript"],
                  ],
    command  => "/sbin/chkconfig --add ${dsearch_service}; /sbin/chkconfig ${dsearch_service} on",
    onlyif    =>  "/usr/bin/test `/sbin/chkconfig --list | /bin/grep ${dsearch_service} | /usr/bin/wc -l` -eq 0",
  }


  exec { "dsearch-create":
    command     => "${xplore_home}/setup/dsearch/dsearchConfig.bin LAX_VM ${xplore_home}/java64/1.8.0_77/jre/bin/java -f ${installer_location}/dsearch/dsearch.properties -r /home/xplore/sig/dsearch/response.properties",
    cwd         => "${xplore_home}/setup/dsearch",
    require     => [File["dsearch-response"],
                    User["${xplore_owner}"],
                    ],
    environment => ["HOME=/home/${xplore_owner}",
                    ],
    creates     => "${xplore_home}/wildfly9.0.1/server/startPrimaryDsearch.sh",
    user        => $xplore_owner,
    group       => $xplore_group,
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
