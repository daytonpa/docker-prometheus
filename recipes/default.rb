#
# Cookbook:: docker-prometheus
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

# create our prometheus user:group
user node['docker-prometheus']['user']['name'] do
  comment node['docker-prometheus']['user']['home']
  manage_home true
  home node['docker-prometheus']['home']
  shell node['docker-prometheus']['user']['shell']
  system true
end

group node['docker-prometheus']['group']['name'] do
  members node['docker-prometheus']['group']['members']
  system true
end

# download prometheus and unpack it
promv = node['docker-prometheus']['source']['version']
promfn = node['docker-prometheus']['source']['filename']

remote_file "#{Chef::Config[:file_cache_path]}/#{promfn}" do
  source "https://github.com/prometheus/prometheus/releases/download/v#{promv}/#{promfn}"
  owner node['docker-prometheus']['user']['name']
  group node['docker-prometheus']['group']['name']
  checksum node['docker-prometheus']['source']['checksum']
  mode '0755'
  action :create
  not_if "#{node['docker-prometheus']['home']}/prometheus --version 2>&1 | grep '#{promv}'"
end

execute 'install prometheus' do
  user node['docker-prometheus']['user']['name']
  command <<-COMMAND
    tar -C #{node['docker-prometheus']['home']}/ \
      -xzf #{Chef::Config[:file_cache_path]}/#{promfn} \
      --strip-components=1
  COMMAND
  not_if "#{node['docker-prometheus']['home']}/prometheus --version 2>&1 | grep '#{promv}'"
end

# verify directories
[
  node['docker-prometheus']['config']['directory.config'],
  node['docker-prometheus']['config']['directory.data'],
  node['docker-prometheus']['config']['directory.libraries'],
  node['docker-prometheus']['config']['directory.rules'],
  node['docker-prometheus']['config']['directory.templates'],
].each do |prom_dir|
  directory prom_dir do
    owner node['docker-prometheus']['user']['name']
    group node['docker-prometheus']['group']['name']
    mode '0750'
  end
end

# configs
conf_dir = node['docker-prometheus']['config']['directory.config']
conf_file = node['docker-prometheus']['config']['scrape-filename']

# scrape
template "#{conf_dir}/#{conf_file}" do
  owner node['docker-prometheus']['user']['name']
  group node['docker-prometheus']['group']['name']
  mode '0640'
  source 'prometheus.yml.erb'
  variables(
    prom_version: node['docker-prometheus']['source']['version'],
    scrape_interval: node['docker-prometheus']['config']['scrape-interval'],
    evaluation_interval: node['docker-prometheus']['config']['evaluation-interval'],
    rules_dir: node['docker-prometheus']['config']['directory.rules'],
    targets: node['docker-prometheus']['config']['targets']
  )
end

# rules
node['docker-prometheus']['config']['targets'].each do |target|
  template "#{node['docker-prometheus']['config']['directory.rules']}/#{target['name']}.yml" do
    owner node['docker-prometheus']['user']['name']
    group node['docker-prometheus']['group']['name']
    mode '0640'
    source 'rules.yml.erb'
    variables(
      target_name: target['name']
    )
  end
end

# generate our startup script for ENTRYPOINT
template node['docker-prometheus']['entrypoint'] do
  owner node['docker-prometheus']['user']['name']
  group node['docker-prometheus']['group']['name']
  mode '0744'
  source 'entrypoint.sh.erb'
  variables(
    prom_version: node['docker-prometheus']['source']['version'],
    prom_bin: "#{node['docker-prometheus']['home']}/prometheus",
    rules_dir: node['docker-prometheus']['config']['directory.rules']
  )
end
