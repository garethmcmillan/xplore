# == Class: xplore
#
# Performs initial configuration tasks for all Vagrant boxes.
# http://www.puppetcookbook.com/posts/add-a-unix-group.html
# https://docs.puppetlabs.com/guides/techniques.html#how-can-i-ensure-a-group-exists-before-creating-a-user
# http://theruddyduck.typepad.com/theruddyduck/2013/11/using-puppet-to-configure-users-groups-and-passwords-for-cloudera-manager.html
# http://stackoverflow.com/questions/19024134/calling-puppet-defined-resource-with-multiple-parameters-multiple-times

class xplore {
  file { '/home/xplore/.bashrc':
      owner => 'xplore',
      group => 'xplore',
      mode  => '0644',
      source => 'puppet:///modules/documentum/bashrc.sh';
  }

  include xplore::server::server
  include xplore::server::dsearch
#  include xplore::server::indexagent

  Class [ 'xplore::server::server' ]     ->
  Class [ 'xplore::server::dsearch' ]    
#  Class [ 'xplore::server::indexagent' ]
}
