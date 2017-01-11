# == Define: indexagent
#
# Adds an Apache configuration file.
# http://stackoverflow.com/questions/19024134/calling-puppet-defined-resource-with-multiple-parameters-multiple-times
#
class xplore::server::indexagent() {
  $installer       = '/u01/app/xplore/setup/indexagent'
  $xplore_home     = '/u01/app/xplore'
# note this should only be the first two ports, eg if 9300, use 93
  $xplore_port     = '9300'
  $xplore_host     = $hostname

  $ia_name         = 'Indexagent'
  $ia_port         = '9200'
  $ia_pass         = '1234qwer'

  $repo            = 'fcms'
  $repo_user       = 'dmadin'
  $repo_pass       = 'vagrant'
  $docbroker_host  = $hostname
  $docbroker_port  = '1489'
  $globalrepo      = 'fcms'
  $globaluser      = 'dm_bof_registry'
  $globalpasswod   = '1234qwer'

  # template(<FILE REFERENCE>, [<ADDITIONAL FILES>, ...])
  file { 'ia-response':
    ensure    => file,
    path      => '/home/xplore/sig/ia/indexagent.properties',
    owner     => xplore,
    group     => xplore,
    content   => template('xplore/indexagent.properties.erb'),
  }

  exec { "ia-create":
    command     => "${installer}/configIndexagent.sh -f /home/xplore/sig/ia/indexagent.properties -r /home/xplore/sig/ia/response.properties -i Silent",
    cwd         => $installer,
    require     => [File["ia-response"],
                    User["xplore"],
                    ],
    environment => ["HOME=/home/xplore",
                    ],
    creates     => "${xplore_home}/wildfly9.0.1/server/startIndexagent.sh",
    user        => xplore,
    group       => xplore,
    logoutput   => true,
    timeout     => 3000,
  }

  exec { "ia-start":
    command     => "${xplore_home}/wildfly9.0.1/server/startIndexagent.sh",
    require     => [Exec["ia-create"],
                    ],
    cwd         => $installer,
    user        => xplore,
    group       => xplore,
  }

}
