require 'optparse'
require 'json'
require 'thrift'

# include top level directory in require path
# set relative_dir_to_top_ruby is the relative path to the ruby directory at the top of the ruby tree.
relative_dir_to_top_ruby = '../..'
# this line is boilerplate - shouldn't need to be edited for different file locations
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby))) unless
    $:.include?(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby)) || $:.include?(File.expand_path(File.join(File.dirname(__FILE__), relative_dir_to_top_ruby)))

require 'utils/lm_config'
require 'utils/lm_log'
require 'queuing/lqueue'
require 'transmit_to_ingest/transmit_thrift_http/thrift_protocol'

class LogManagementThrift

  def initialize(cfg)
    @queue_host = cfg.queues.output_aggregated.hostname
    @queue_port = cfg.queues.output_aggregated.port
    @queue_files_directory = cfg.queues.output_aggregated.filestorage
    @queue = LQueue.new "output_aggregated", cfg

    @ingest_host = cfg.ingest.host
    @ingest_port = cfg.ingest.port

    # true while running.  Set to false to stop the loop
    @reading_flag = false

    # create the logger
    @logger = logger = LMLog.new cfg
    @logger.info "Transmit to ingest LogManagementThrift initialized."
  end

  def start
    @logger.info "Transmit to ingest LogManagementThrift starting."
    @reading_flag = true
    while @reading_flag
      job, data = @queue.reserve timeout=5
      unless data == nil
        @logger.debug "Sending: #{data}"
        begin
          send data
        rescue => ex
          @logger.exception ex, 'Exception trying to send data to ingest - requeuing the request'
          job.release # requeue at a lower priority
        else
          # only delete if it was safely sent
          @queue.delete job
        end
      end
    end
    @logger.info "Transmit to ingest LogManagementThrift stopped."
  end

  def stop
    @logger.info "Stopping Transmit to ingest LogManagementThrift"
    @reading_flag = false
  end

  # convert json data to array for LogManagementProtocol.appendBatch call
  def self.jsondata_to_logm_records(json_data)
    # break json array into separate records (array of hashes)
    records = JSON.parse(json_data)

    logm_records = Array.new
    records.each do |record|
      ### temporary - fix input data to include this information
      record["tag"] = record["eventId"] # what should this be?

      time = nil
      if record.has_key?("startTime")
        time = record["startTime"]
      elsif record.has_key?("agentReceiptTime")
        time = record["agentReceiptTime"]
      end

      logm_record = LogManagementRecord.new()
      logm_record.headers = {'client' => record["customerId"], 'tag' => record["customerId"], 'time' => time.to_s}
      logm_record.body = record.to_json.to_s.force_encoding('UTF-8')
      logm_records.push(logm_record)

    end

    logm_records

  end


  # send a chunk of data to the server
  def send(json_data)
      socket = Thrift::Socket.new(@ingest_host, @ingest_port)
      transport = Thrift::BufferedTransport.new(socket)
      protocol = Thrift::BinaryProtocol.new(transport)
      client = LogManagementThriftProtocol::Client.new(protocol)

      transport.open()

      logm_records = LogManagementThrift.jsondata_to_logm_records(json_data)

      client.appendBatch(logm_records)
      transport.close()
  end
end

if __FILE__ == $0
  options = {}
  OptionParser.new do |opts|
    #opts.banner = "Usage: example.rb [options]"

    opts.on("-c CONFIG_FILE_PATH", "--config-file CONFIG_FILE_PATH", "Specify config file") do |f|
      options[:config_file] = f
    end

  end.parse!

  if options.count == 0
    puts "For usage information, use ruby transmit_to_ingest.rb --help"
    exit
  end


  cfg = LMConfig.new(options[:config_file])
  l = LogManagementThrift.new(cfg)

  l.start

  #
  # testing suggestion if flume not running
  #   run: nc -l 0.0.0.0 5143

end