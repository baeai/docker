# write text to local storage area
require  'logger'
# include top level directory in require path
# set relative_dir_to_top_ruby is the relative path to the ruby directory at the top of the ruby tree.
relative_dir_to_top_ruby = '..'
# this line is boilerplate - shouldn't need to be edited for different file locations
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby))) unless
    $:.include?(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby)) || $:.include?(File.expand_path(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby)))

require 'utils/lm_log'

class LogEventsLocalStorage
  def initialize cfg
    @cfg = cfg
    @logger = LMLog.new cfg, name=LogEventsLocalStorage
    @local_storage_logger = Logger.new @cfg.input_events.saved_events_log
    @local_storage_logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end
    @logger.debug "Local Storage file: #{@cfg.input_events.saved_events_log}"
  end

  def save_event(text)
    begin
      @logger.debug "Saving to local storage: #{text}"
      @local_storage_logger.info text
    rescue => ex
      @logger.exception ex, "Exception thrown saving to local storage"
    end
  end
end
