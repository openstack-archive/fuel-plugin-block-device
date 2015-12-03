notice('MODULAR: block-device/cinder-scheduler-filters.pp')

class { 'cinder::scheduler::filter':
  scheduler_default_filters => [ 'InstanceLocalityFilter', 'AvailabilityZoneFilter', 'CapacityFilter', 'CapabilitiesFilter' ],
}

Cinder_config<||> ~> Service<| title == 'cinder-api' |>
Cinder_config<||> ~> Service<| title == 'cinder-scheduler' |>
