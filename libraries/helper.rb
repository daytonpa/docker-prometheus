
def generate_prometheus_runtime_flags
  @config = ''
  node['docker-prometheus']['config']['flags'].each do |conf_idx, conf_val|
    if [true, false].include? conf_val
      @config << "--#{conf_idx} " if conf_val
    else
      @config << "--#{conf_idx}=#{conf_val} "
    end
  end
  @config
end
