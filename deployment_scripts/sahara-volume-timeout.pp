notice('MODULAR: block-device/sahara-volume-timeout.pp')

sahara_config {
  'timeouts/await_attach_volumes': value => '60';
}
