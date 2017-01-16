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
  $xplore_host     = $hostname
  $xplore_password = '1234qwer'
  $xplore_admin    = 'admin'

  # template(<FILE REFERENCE>, [<ADDITIONAL FILES>, ...])
  file { 'dsearch-response':
    ensure    => file,
    path      => '/home/xplore/sig/dsearch/dsearch.properties',
    owner     => xplore,
    group     => xplore,
    content   => template('xplore/dsearch.properties.erb'),
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

  exec { "dseach-start":
    command     => "nohup ${xplore_home}/wildfly9.0.1/server/startPrimaryDsearch.sh &",
    require     => [Exec["dsearch-create"],
                    ],
environment => ["HOME=/home/xplore",
                  ],                    
    cwd         => $installer,
    user        => xplore,
    group       => xplore,
  }

}
