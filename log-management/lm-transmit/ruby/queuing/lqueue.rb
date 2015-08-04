require 'beanstalk-client'
require 'fileutils'
require 'securerandom'

# include top level directory in require path
# set relative_dir_to_top_ruby is the relative path to the ruby directory at the top of the ruby tree.
relative_dir_to_top_ruby = '..'
# this line is boilerplate - shouldn't need to be edited for different file locations
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby))) unless
    $:.include?(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby)) || $:.include?(File.expand_path(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby)))

require 'utils/lm_log'


class LQueueUtils
  # convert an ip address into a tube name
  def self.calculate_tube_name(ip, source_port)
    return "events_from_#{ip}_#{source_port}"
  end
end

# queues for LogManagement are accessed through this class
# create an instance per queue to be accessed
# be aware that queue files are referred to by queue items and need to be accessible from this process via the given directory
class LQueue
  attr_reader :valid

  def initialize(queue_name, cfg)

    @valid = false
    @queue_name = queue_name
    @cfg = cfg

    @logger = LMLog.new @cfg

    q = cfg["queues"][queue_name]
    if q
      @host = q["hostname"]
      @port = q["port"]
      @directory = q["filestorage"]
    else
      return
    end

    do_initialize
  end

  def do_initialize
    # create the directory if it doesn't already exist
    begin
      FileUtils::mkdir_p @directory
    rescue
      # I guess it already exists
    end

    # connect to beanstalk process
    @queue = nil
    begin
      @queue = Beanstalk::Pool.new(["#{@host}:#{@port}"])
    rescue => e
      # log the exception and fail to create a queue
      @logger.exception e, "Failed to create queue"
    end

    if @queue != nil
      @valid = true
    end

    @logger = LMLog.new @cfg

  end

  # make file path from an id
  def make_file_path(id)
    File.join(@directory, id + '.queueitem')
  end

  # add an string item to the queue
  def put(string_item)
    unless @queue
      return 0
    end

    # generate a guid
    id = SecureRandom.uuid

    # save the string_item in a file
    begin
      File.open(make_file_path(id), 'w') do |f|
        f.write(string_item)
      end
    rescue => ex
      @logger.exception(ex, "Exception when writing to queue file, path=#{make_file_path(id)}")
    end

    @queue.put(id)
  end

  # release a job back into the queue - maybe we never were able to process it so don't delete it yet
  # optional lower_priority = true will change the priority to a lower one (higher number) so it goes to the back of the queue
  def release(job, lower=true)
    unless @queue
      return
    end

    begin
      if lower
        newpriority = 2++31+10
        job.release newpri=newpriority
      else
        job.release
      end
    end
  end

  # get a job off the queue
  # returns the job object and the data from the related file as [job, data]
  # timeout is number of seconds to wait for the job. nil means wait forever.
  def reserve(timeout=5)
    unless @queue
      return [nil, nil]
    end

    # in case files have been deleted, read until we find a useful queue item (or the end of the queue is reached)
    file_was_read = false
    while !file_was_read
      begin
        job = @queue.reserve timeout=timeout
      rescue
        return [nil, nil]
      end

      # get the data from the file system
      begin
        data = ""
        File.open(make_file_path(job.body), 'r') do |f|
          data = f.read
        end
        file_was_read = true
      rescue => ex
        job.delete  # just the queue item, since the file is missing
        @logger.exception ex, "LQueue reserve error - problem reading file #{make_file_path(job.body)}"
      end

    end

    # return the job and data objects
    [job, data]
  end

  # delete a job from the queue
  # don't use job.delete directly since it doesn't delete the related file
  def delete(job)
    unless @queue
      return
    end

    id = job.body

    # delete the queue item
    begin
      job.delete
    rescue => ex
      @logger.exception ex, "Exception thrown when deleting a job from queue #{@host}:#{@port}"
    end

    # delete the file
    begin
      FileUtils.rm(make_file_path(id))
    rescue => ex
      @logger.exception("Exception thrown when deleting #{make_file_path(id)}")
    end
  end

  # get stats
  # return value can be used to get ["current-jobs-ready"] or ["current-jobs-reserved"]
  def stats
    unless @queue
      return {}
    end

    @queue.stats()
  end

  # use_tube - which tube are we going to PUT our next item into
  def use_tube(tubename)
    @queue.use tubename
  end

  # watch_tube - which tube are we going to GET our next item from
  def watch_tube(tubename)
    @queue.watch tubename
  end

  # tube counts - get counts of ready and reserved items from all queues except for tube=='default'
  # returns a hash by tube name of the stats for that tube (another hash)
  # so to get current-jobs-ready for tube named 'abc', check the return value ret['abc']['current-jobs-ready']
  def tube_counts
    tc = {}
    unless @queue == nil
      tubes = @queue.list_tubes # this is probably some buggy ruby code, but it's what we have.  It returns a stupid hash to an array - messy to unravel
      tubes.values[0].each do |tubename|
        unless tubename == 'default'
          tc[tubename] = @queue.stats_tube tubename
        end
      end
    end

    tc

  end

end
