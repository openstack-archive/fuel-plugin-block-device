class { 'cinder::scheduler::filter':
  scheduler_default_filters => [ 'InstanceLocalityFilter', 'AvailabilityZoneFilter', 'CapacityFilter', 'CapabilitiesFilter' ],
}
