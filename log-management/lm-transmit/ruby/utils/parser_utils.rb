
class ParserUtils

  def self.convert_ip_to_long(ip_address)
    m = /((\d+)\.(\d+)\.(\d+)\.(\d+))/.match(ip_address)
    return 0 if m.nil?

    o1 = m[2].to_i
    o2 = m[3].to_i
    o3 = m[4].to_i
    o4 = m[5].to_i

    return o1*(256*256*256) + o2 * (256*256) + o3 * 256 + o4
  end

end

# generate unique event identifiers
class EventIdGenerator
  @@max_event_counter = 999999

  # the agent id should be unique for each instance of the EventIdGenerator, but not too long
  def initialize(agentid)
    @agentid = agentid
    @counter = 0
  end

  def next_event_id()
    @counter += 1
    @counter = 0 if @counter > @@max_event_counter
    "#{@agentid}#{DateTime.now.strftime('%Q').to_s}#{@counter}"
  end
end