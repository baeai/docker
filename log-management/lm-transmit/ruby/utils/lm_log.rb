require 'logger'

# include top level directory in require path
# set relative_dir_to_top_ruby is the relative path to the ruby directory at the top of the ruby tree.
relative_dir_to_top_ruby = '..'
# this line is boilerplate - shouldn't need to be edited for different file locations
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby))) unless
    $:.include?(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby)) || $:.include?(File.expand_path(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby)))

require 'utils/lm_config'

# logger wrapper for Log Management
class LMLog
  def initialize(cfg, name=nil)
    @output_file = cfg.logging.output_file

    # create the directory if it doesn't exist yet
    dir = File.dirname(@output_file)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    # now use it
    @logger = Logger.new @output_file
    if name
      @logger.progname = "#{File.basename($0)}:#{name}"
    else
      @logger.progname = File.basename $0
    end
    set_log_level cfg.logging.log_level
  end

  # set the log level
  def set_log_level(log_level)
    case log_level.downcase
      when 'debug'
        @logger.level = Logger::DEBUG
      when 'info'
        @logger.level = Logger::INFO
      when 'warn'
        @logger.level = Logger::WARN
      when 'error'
        @logger.level = Logger::ERROR
      when 'fatal'
        @logger.level = Logger::FATAL
    end
  end

  def debug(msg)
    @logger.debug msg
  end

  def info(msg)
    @logger.info msg
  end

  def warn(msg)
    @logger.warn msg
  end

  def error(msg)
    @logger.error msg
  end

  # handy for logging an exception backtrace
  def exception(ex, msg='')
    line = ''
    ex.backtrace.each do |l|
      line += "\n  #{l}"
    end
    @logger.error "#{msg}: ** Exception thrown: #{ex.class}, backtrace follows:#{line}"
  end
end
