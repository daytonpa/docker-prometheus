#
# Cookbook:: docker-prometheus
# Spec:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'docker-prometheus::default' do
  {
    'centos' => PlatformVersions.centos,
    'ubuntu' => PlatformVersions.ubuntu,
  }.each do |platform_name, platform_versions|
    platform_versions.each do |platform_version|
      context "When all attributes are default, on #{platform_name} #{platform_version}" do
        before do
          stub_command("/opt/prometheus/prometheus --version 2>&1 | grep '2.15.2'").and_return(false)
        end
        # for a complete list of available platforms and versions see:
        # https://github.com/chefspec/fauxhai/blob/master/PLATFORMS.md
        platform platform_name, platform_version

        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end
      end
    end
  end
end
