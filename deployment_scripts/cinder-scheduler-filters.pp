notice('MODULAR: block-device/cinder-scheduler-filters.pp')

include ::cinder::params

notify { 'Updating cinder.conf': }

class { 'cinder::scheduler::filter':
  scheduler_default_filters => [ 'InstanceLocalityFilter', 'AvailabilityZoneFilter', 'CapacityFilter', 'CapabilitiesFilter' ],
}

service { 'cinder-api':
  ensure    => 'running',
  name      => $::cinder::params::api_service,
  hasstatus => true,
}

service { 'cinder-scheduler':
  ensure    => 'running',
  name      => $::cinder::params::scheduler_service,
  hasstatus => true,
}

Class['cinder::scheduler::filter'] -> Notify['Updating cinder.conf']
Notify['Updating cinder.conf'] ~> Service['cinder-api']
Notify['Updating cinder.conf'] ~> Service['cinder-scheduler']
