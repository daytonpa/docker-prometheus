name 'docker-prometheus'
maintainer 'Patrick Dayton'
maintainer_email 'daytonpa@gmail.com'
license 'Apache-2.0'
description 'Installs/Configures docker-prometheus'
version '0.1.0'
chef_version '>= 14.0'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
issues_url 'https://github.com/daytonpa/docker-prometheus/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
source_url 'https://github.com/daytonpa/docker-prometheus'

supports 'ubuntu', '= 18.04'
supports 'centos', '= 8'
