require 'json'

def is_number? string
  true if Float(string) rescue false
end

class LMConfigEntry
  # empty class to represent a nested set of values or LMConfigEntry's
  # members are added dynamically
end

# This class wraps the config file
# usage:
#   cfg = LMConfig.new path-to-config-file
#   access the config settings either of 2 ways
#     port = cfg.queues.output_aggregated.port
#        or
#     port = cfg["queues"]["output_aggregated"]["port"]
#

class LMConfig
  @config_values = nil
  def initialize(config_path)
     File.open(config_path, 'r') do |f|
       @config_values = JSON.parse(f.read)
     end
    LMConfig.set_members(self, @config_values)
  end

  # this method allows you to do something like LMConfig.new["somekey"]
  # this is useful for enumerating nested values, such as all the queue names under ["queues"]
  def [](key)
    ret = nil
    begin
      ret = @config_values[key]
    rescue
    end

    return ret
  end

  # this method is cool. It takes the @config_values hash and turns it into direct ruby members
  # so this allows something like LMConfig.new.somekey
  def self.set_members(obj, hash)
    hash.each do |k, v|
      if v.class == Hash
        tmp = LMConfigEntry.new
        # call recursively to set included hashes to be members of the new object
        LMConfig.set_members(tmp, v)
        # create an instance variable that we can add members to
        obj.instance_variable_set("@#{k}", tmp)
      else # (Fixnum, String or Array)
        # create and initialize an instance variable for this key/value pair
        obj.instance_variable_set("@#{k}", v)
      end
      # create the getter that returns the instance variable
      obj.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})
    end
  end

  def sources_by_ip_and_port()
    logsources_by_ip_and_port = {}
    @config_values["log_sources"].each do |source_name, source_params|
      source_params["source_ips"].each do |ip|
        # add the ip address to the hashtable if not there yet

        logsources_by_ip_and_port[ip] = {} unless logsources_by_ip_and_port.has_key? ip

        # add the port number if it's not there yet
        port = source_params["receiving_port_number"]
        logsources_by_ip_and_port[ip][port] = [] unless logsources_by_ip_and_port[ip].has_key? port

        # add this log source to the list for this port
        logsources_by_ip_and_port[ip][port].push source_name
      end
    end
    return logsources_by_ip_and_port
  end

end