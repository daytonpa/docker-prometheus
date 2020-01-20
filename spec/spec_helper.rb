require 'chefspec'
require 'chefspec/policyfile'

module PlatformVersions
  @centos = %w( 8 )
  @ubuntu = %w( 18.04 )

  def self.amazon
    @amazon
  end

  def self.centos
    @centos
  end

  def self.ubuntu
    @ubuntu
  end
end
