class LogFileParser
  def initialize(path)
    raise ArgumentError unless File.exists?( path )
    @results = Hash.new
    @log = File.open( path )
  end

  def emit
    logs = @log.inject({}) do |log, line|
      value = line.split(' ')
      log.merge!( value[0] => log[value[0]].nil? ? [] << value.last : log[value[0]] << value.last )
    end

    @results = logs.inject({}) do |results, (key, values)|
      max_ip_used = values.max_by { |i| values.count(i) }
      results.merge!({ key => { total_count: values.count, unique_count: values.uniq.count, max_ip_used: max_ip_used, max_ip_used_count: values.count(max_ip_used) }})
    end.sort_by { |k, v| -v[:total_count] }

    @results.each do |key, value|
      puts " *************************************"
      puts " **** URL : #{key} *****"
      puts " **** Total Count : #{value[:total_count]} *****"
      puts " **** Unique Count : #{value[:unique_count]} *****"
      puts " **** Max IP Used : #{value[:max_ip_used]} *****"
      puts " **** Max IP Used Count : #{value[:max_ip_used_count]} *****"
      puts " *************************************"
    end
  end
end

parser = LogFileParser.new(*ARGV)
parser.emit