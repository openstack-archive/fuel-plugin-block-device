notice('MODULAR: block-device/cinder-block-device.pp')

prepare_network_config(hiera('network_scheme', {}))

$storage_address            = get_network_role_property('cinder/iscsi', 'ipaddr')
$management_vip             = hiera('management_vip')
$verbose                    = true
$debug                      = hiera('debug', true)
$nodes_hash                 = hiera('nodes', {})
$glance_api_servers         = hiera('glance_api_servers', "${management_vip}:9292")
$storage_hash               = hiera_hash('storage_hash', {})
$rabbit_hash                = hiera_hash('rabbit_hash', {})
$cinder_hash                = hiera_hash('cinder_hash', {})
$ceilometer_hash            = hiera_hash('ceilometer_hash',{})
$queue_provider             = hiera('queue_provider', 'rabbitmq')
$service_endpoint           = hiera('service_endpoint')
$use_stderr                 = hiera('use_stderr', false)
$use_syslog                 = hiera('use_syslog', true)
$syslog_log_facility_cinder = hiera('syslog_log_facility_cinder', 'LOG_LOCAL3')
$cinder_block_device        = hiera_hash('cinder_block_device_driver')

$cinder_db_password         = $cinder_hash[db_password]
$cinder_db_user             = pick($cinder_hash['db_user'], 'cinder')
$cinder_db_name             = pick($cinder_hash['db_name'], 'cinder')
$cinder_block_device_scheme = parseyaml($cinder_block_device['block_device_scheme']['content'])
$db_host                    = pick($cinder_hash['db_host'], hiera('database_vip'))
$keystone_user              = pick($cinder_hash['user'], 'cinder')
$keystone_tenant            = pick($cinder_hash['tenant'], 'services')
$rabbit_user                = pick($rabbit_hash['user'], 'nova')

$keystone_auth_protocol = 'http'
$keystone_auth_host     = $service_endpoint
$service_port           = '5000'
$auth_uri               = "${keystone_auth_protocol}://${keystone_auth_host}:${service_port}/"

if empty($node) {
  fail("Node $::hostname is not defined in the hash structure")
}

# TODO: openstack_version is confusing, there's such string var in hiera and hardcoded hash
$hiera_openstack_version = hiera('openstack_version')
$openstack_version = {
  'keystone'   => 'installed',
  'glance'     => 'installed',
  'horizon'    => 'installed',
  'nova'       => 'installed',
  'novncproxy' => 'installed',
  'cinder'     => 'installed',
}

$max_pool_size = min($::processorcount * 5 + 0, 30 + 0)
$max_overflow  = min($::processorcount * 5 + 0, 60 + 0)
$max_retries   = '-1'
$idle_timeout  = '3600'

Exec { logoutput => true }

include keystone::python
package { 'python-amqp':
  ensure => present
}

class { 'openstack::cinder':
  amqp_hosts           => hiera('amqp_hosts',''),
  amqp_password        => $rabbit_hash['password'],
  amqp_user            => $rabbit_hash['user'],
  auth_uri             => $auth_uri,
  bind_host            => false,
  ceilometer           => $ceilometer_hash[enabled],
  cinder_user_password => $cinder_hash[user_password],
  debug                => $debug,
  enable_volumes       => false,
  glance_api_servers   => $glance_api_servers,
  identity_uri         => $auth_uri,
  idle_timeout         => $idle_timeout,
  iscsi_bind_host      => $storage_address,
  iser                 => $storage_hash['iser'],
  keystone_tenant      => $keystone_tenant,
  keystone_user        => $keystone_user,
  manage_volumes       => false,
  max_overflow         => $max_overflow,
  max_pool_size        => $max_pool_size,
  max_retries          => $max_retries,
  queue_provider       => $queue_provider,
  rabbit_ha_queues     => hiera('rabbit_ha_queues', false),
  sql_connection       => "mysql://${cinder_db_user}:${cinder_db_password}@${db_host}/${cinder_db_name}?charset=utf8&read_timeout=60",
  syslog_log_facility  => $syslog_log_facility_cinder,
  use_stderr           => $use_stderr,
  use_syslog           => $use_syslog,
  verbose              => $verbose,
  volume_group         => 'cinder',
}

$available_devices = $cinder_block_device_scheme[$node['name']]

class { 'cinder::volume':
  package_ensure => $::openstack_version['cinder'],
  enabled        => $enable_volumes,
}

class { 'cinder::volume::iscsi':
  iscsi_ip_address => $storage_address,
  volume_group     => 'cinder',
  volume_driver    => 'cinder.volume.drivers.block_device.BlockDeviceDriver',
}

cinder_config {
  'keymgr/fixed_key':          value => $cinder_hash[fixed_key];
  'DEFAULT/auth_strategy':     value => 'keystone';
  'DEFAULT/available_devices': value => $available_devices;
  'DEFAULT/iscsi_helper':      value => 'fake';
}
