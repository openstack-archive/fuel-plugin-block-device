notice('MODULAR: block-device/cinder-scheduler-filters.pp')

include ::cinder::params

class { 'cinder::scheduler::filter':
  scheduler_default_filters => [ 'InstanceLocalityFilter', 'AvailabilityZoneFilter', 'CapacityFilter', 'CapabilitiesFilter' ],
}

service { 'cinder-api':
  name      => $::cinder::params::api_service,
  hasstatus => true,
}

service { 'cinder-scheduler':
  name      => $::cinder::params::scheduler_service,
  hasstatus => true,
}

Class['cinder::scheduler::filter'] ~> Service<| title == 'cinder-api' |>
Class['cinder::scheduler::filter'] ~> Service<| title == 'cinder-scheduler' |>
