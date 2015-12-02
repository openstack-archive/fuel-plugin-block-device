fuel-plugin-bdd
===============

Disk-intensive workloads require the storage layer to be able to provide both
high IOPS and sequential operations capabilities. Apache Hadoop is one of the
most storage-sensitive frameworks which is widely used for Data Processing in
production. Sahara service provides Hadoop installations on top of OpenStack.

The best performance on the virtualized environment can be achieved by
providing the direct access from a VM to a block device located on the same
compute host. OpenStack Cinder service has such attachment option implemented
in the BlockDeviceDriver.

This plugin affords ability to use BlockDeviceDriver in Fuel.
