# include top level directory in require path
# set relative_dir_to_top_ruby is the relative path to the ruby directory at the top of the ruby tree.
relative_dir_to_top_ruby = '..'
# this line is boilerplate - shouldn't need to be edited for different file locations
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby))) unless
    $:.include?(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby)) || $:.include?(File.expand_path(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby)))

require 'utils/lm_config'

# this is a rough class that can be used by unittesting
# the idea is to read a starter config file, then override the values in this object
#  before passing it on to something to be tested.
# NOTE: to change a value, change it both ways - both the object and the hash table way
# for example, to change a queue port, you might need to do both of these things to cover either way it might be used:
#   cfg["queues"]["output_single"]["port"] = 1234
#     and
#   cfg.queues.output_single.port = 1234
class LMConfigUnittest < LMConfig
  def initialize(config_path, replace_sources=nil)
    File.open(config_path, 'r') do |f|
      @config_values = JSON.parse(f.read)
    end

    # --- Unittest-ify this data
    unittest_dir = '/tmp/lm_unittest'

    # make sure we change the customer id to something safe
    @config_values["client"]["customer_id"] = "Unittest_customer_id"

    # unittests should use different binlog directory and ports
    @config_values["queue_setup"]["binlog_directory"] = "#{unittest_dir}/binlogs"
    FileUtils.mkdir_p @config_values["queue_setup"]["binlog_directory"]

    # subtract 1000 from all queue ports and set their file storage directories
    @config_values["queues"].each do |queuename, vals|
      vals["port"] -= 1000
      vals["filestorage"] = "#{unittest_dir}/queue_files/p_#{vals["port"]}"
      FileUtils.mkdir_p vals["filestorage"]
    end

    # ingest will be listening somewhere different as well
    @config_values["input_events"]["saved_events_log"] = "#{unittest_dir}/saved_events.log"
    @config_values["ingest"]["port"] += 1000

    # if we want to replace log_sources section, replace_sources will contain the json to put there
    if replace_sources
      @config_values["log_sources"] = JSON.parse(replace_sources)["log_sources"]
    end

    LMConfigUnittest.set_members(self, @config_values)

  end

  def self.set_members(obj, hash)
    hash.each do |k, v|
      if v.class == Hash
        tmp = LMConfigEntry.new
        # call recursively to set included hashes to be members of the new object
        LMConfigUnittest.set_members(tmp, v)
        # create an instance variable that we can add members to
        obj.instance_variable_set("@#{k}", tmp)
      else
        # create and initialize an instance variable for this key/value pair
        obj.instance_variable_set("@#{k}", v)
      end
      # create the getter that returns the instance variable
      obj.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})

      # also create a setter that sets the instance variable - we don't need to do this but leaving it in for reference in case we change our minds
      obj.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})
    end
  end
end