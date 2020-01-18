#
# Cookbook:: docker-prometheus
# Attributes:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

default['docker-prometheus']['home'] = '/opt/prometheus'
default['docker-prometheus']['entrypoint'] = '/entrypoint.sh'
default['docker-prometheus']['user'].tap do |usr|
  usr['name'] = 'prometheus'
  usr['shell'] = '/bin/bash'
end
default['docker-prometheus']['group'].tap do |grp|
  grp['name'] = 'prometheus'
  grp['members'] = %W( #{node['docker-prometheus']['user']['name']} root )
end
default['docker-prometheus']['source'].tap do |src|
  src['version'] = '2.15.2'
  src['filename'] = "prometheus-#{src['version']}.linux-amd64.tar.gz"
  src['checksum'] = '579f800ec3ec2dc9a36d2d513e7800552cf6b0898f87a8abafd54e73b53f8ad0'
end
default['docker-prometheus']['config'].tap do |cfg|
  cfg['directory.config'] = '/etc/prometheus'
  cfg['directory.data'] = "#{node['docker-prometheus']['home']}/data"
  cfg['directory.libraries'] = "#{node['docker-prometheus']['home']}/console_libraries"
  cfg['directory.rules'] = "#{cfg['directory.config']}/rules"
  cfg['directory.templates'] = "#{node['docker-prometheus']['home']}/consoles"
  cfg['scrape-filename'] = 'prometheus.yml'
  cfg['scrape-interval'] = '15s'
  cfg['scrape-timeout'] = '10s'
  cfg['evaluation-interval'] = '15s'
  cfg['targets'] = [
    {
      'name': 'default',
      'ip_addresses': %w( localhost ),
      'port': 9090,
      'scrape_path': '/metrics',
    },
  ]
end
default['docker-prometheus']['config']['flags'].tap do |flgs|
  flgs['config.file'] = "#{node['docker-prometheus']['config']['directory.config']}/#{node['docker-prometheus']['config']['scrape-filename']}"
  flgs['web.listen-address'] = '0.0.0.0:9090'
  flgs['web.read-timeout'] = '5m'
  flgs['web.max-connections'] = '15'
  flgs['web.enable-lifecycle'] = true
  flgs['web.enable-admin-api'] = true
  flgs['web.console.templates'] = node['docker-prometheus']['config']['directory.templates']
  flgs['web.console.libraries'] = node['docker-prometheus']['config']['directory.libraries']
  flgs['storage.tsdb.retention.time'] = '30d'
  flgs['storage.tsdb.path'] = node['docker-prometheus']['config']['directory.data']
  flgs['log.level'] = 'debug'
  flgs['log.format'] = 'logfmt'
end
