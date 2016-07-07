require 'yaml'
require 'pg'
require 'ostruct'
require 'optparse'
require 'logger'


# accept table name, sortkeys and distribution key via command-line options
@logger           = Logger.new($stdout)
@query            = ''
@rebuild          = true
@table_name       = ''
@schema_name      = ''
@sortkeys         = nil
@distribution_key = ''
Usage             = "Usage: insert.rb --query=FILE_PATH --rebuild=true --table_name --schema_name --[sortkeys] --distribution_key"


OptionParser.new do |opts|
  opts.on('-q', '--query=file_path', 'path to file containing SQL') {|file_path| @query = File.read(file_path)}
  opts.on('-r', '--rebuild=is_incremental', 'rebuild will truncate the schema and issue create table statements') { |is_incremental| @rebuild = is_incremental }
  opts.on('-t', '--table_name=table', 'name of the table to which we will insert') { |table| @table_name = table }
  opts.on('-c', '--schema_name=schema', 'name of the schema in which the table will be created (default is looker_scratch)') { |schema| @schema_name = schema }
  opts.on('-s', '--sortkeys=x,y,z', String, 'list of column names or aliases that act as sortkey(s)') { |val| @sortkeys = val.split(/\W/) }
  opts.on('-d', '--distribution_key=column', 'the name of the column that acts as the distribution key (default is even distribution)') { |column| @distribution_key = column }
  opts.on('-h', '--help', 'Displays help') {|help| puts opts}
end.parse!(ARGV)


class DeepStruct < OpenStruct
  # DeepStruct pattern borrowed from: http://andreapavoni.com/blog/2013/4/create-recursive-openstruct-from-a-ruby-hash/#.VottepMrJE4
  def initialize(hash=nil)
    @table = {}
    @hash_table = {}

    if hash
      hash.each do |k, v|
        @table[k.to_sym] = (v.is_a?(Hash) ? self.class.new(v) : v)
        @hash_table[k.to_sym] = v

        new_ostruct_member(k)
      end
    end
  end

  def to_h
    @hash_table
  end

end


class Generator

  attr_reader :db

  def initialize
    config    = DeepStruct.new(YAML.load_file("config.yaml"))
    @host     = config.redshift.host
    @port     = config.redshift.port
    @database = config.redshift.database
    @username = config.redshift.username
    @password = config.redshift.password
    @db       = PGconn.connect(@host, @port, '', '', @database, @username, @password)
  end

  def run(statement)
    db.exec(statement)
  end

  def self.get_column_data_types(data_type_code)
    case data_type_code
      when 1042
      	then 'char'
      when 1043, 25
      	then 'varchar'
      when 23
      	then 'integer'
      when 20
      	then 'bigint'
      when 1082
      	then 'date'
      when 1114
      	then 'timestamp without time zone'
      when 1700
      	then 'numeric'
      when 16
      	then 'boolean'
      when 700, 701
      	then 'float'
      else
        'varchar'
    end
  end

  def self.get_encoding_type(data_type, options = {})
    if options[:is_sortkey] || options[:is_distribution_key]
      then ''
    else
      case data_type
        when 'boolean'
          then ' encode runlength'
        when 'timestamp without time zone', 'date', 'integer', 'bigint'
          then ' encode delta'
        when 'varchar', 'char'
          then ' encode lzo'
        else ' encode raw'
      end
    end
  end

  def self.generate_sizes(data_type, column_width)
    # explain verbose adds 4 to the length of a given column—e.g., varchar(200) appears as :restypmod 204
    if (data_type == 'varchar' || data_type == 'char') && column_width >= 4
      then "#{data_type}(#{column_width - 4})"
    elsif (data_type == 'varchar' || data_type == 'char') && column_width < 4
      then "#{data_type}(9999)"
    else
      data_type
    end
  end

  def map_sortkeys!(column_meta_data, sortkeys)
    # this has side effects via in-place additions to an external data structure
    column_meta_data.map{|k, v| sortkeys.include?(k) ? v[:is_sortkey] = true : v[:is_sortkey] = false}
  end

  def map_distkey!(column_meta_data, distribution_key)
    # this has side effects via in-place additions to an external data structure
    column_meta_data.map{|k, v| distribution_key.include?(k) ? v[:is_distribution_key] = true : v[:is_distribution_key] = false}
  end  

  def self.verbose_explain(query)
    "explain verbose #{query}"
  end

  def self.get_column_meta_data(explain)
    column_data = {}
    explain.scan(/restype\s+(\S+)\s+:restypmod+\s+(\S+)\s+:resname\s+(\S+)/).map{|a, b, c| column_data.merge!(c => {:data_type => a.to_i, :data_size => b.to_i})}
    choice_column_data = column_data.select{|k, v| k.match(/[^<>]/)}
    choice_column_data.map{|k, v| v[:data_type] = Generator.get_column_data_types(v[:data_type])}
    choice_column_data
  end

  def self.merge_arrays(a, b, sep = ' ')
    a.zip(b).map{|pair| pair.join(sep)}
  end

  def self.generate_insert_into(destination_table, query)
    "insert into #{destination_table} (#{query})"
  end

  def self.generate_create_table(table_name, column_names, data_types, options = {})
    distribution_argument = options[:distribution_key] ? "distkey(#{options[:distribution_key]})" : "diststyle even"
    sortkey_argument      = options[:sortkeys] ? "sortkey(#{options[:sortkeys].join(', ')})" : ""
    "create table #{table_name} (#{merge_arrays(column_names, data_types).join(', ')}) #{distribution_argument} #{sortkey_argument};"
  end

end


# main procedure

# fire up instance of Generator class
generator = Generator.new

begin
  # get verbose explain text
  lines = generator.run(Generator.verbose_explain(@query)).values.join(' ')
rescue => e
  @logger.error("#{e.message}\n  #{e.backtrace.join("\n  ")}")
  exit(1)
end

begin
  # infer column meta data from verbose explain
  column_meta_data  = Generator.get_column_meta_data(lines)
rescue => e
  @logger.error("#{e.message}\n  #{e.backtrace.join("\n  ")}")
  exit(1)
end

begin
  # update meta data with sort and distribution information
  generator.map_sortkeys!(column_meta_data, @sortkeys)
  generator.map_distkey!(column_meta_data, @distribution_key)
rescue => e
  @logger.error("#{e.message}\n  #{e.backtrace.join("\n  ")}")
  exit(1)
end

begin
  # piece together the data type, size, and encoding for each column, handling sort and distribution
  data_types = column_meta_data.map{|k, v| Generator.generate_sizes(v[:data_type], v[:data_size]) + Generator.get_encoding_type(v[:data_type], options = {:is_sortkey => v[:is_sortkey], :is_distribution_key => v[:is_distribution_key]})}
rescue => e
  @logger.error("#{e.message}\n  #{e.backtrace.join("\n  ")}")
  exit(1)
end

begin
  # generate and issue create-table statement
  create_statement = Generator.generate_create_table("#{@schema_name}.#{@table_name}", column_meta_data.keys, data_types, options = {:sortkeys => @sortkeys, :distribution_key => @distribution_key}) # need to change instance variables to equivalents in meta_data
  generator.run(create_statement)
rescue => e
  @logger.error("#{e.message}\n  #{e.backtrace.join("\n  ")}")
  exit(1)
end

begin
  # generate and issue insert-into statement
  insert_into = Generator.generate_insert_into("#{@schema_name}.#{@table_name}", @query)
  generator.run(insert_into)
rescue => e
  @logger.error("#{e.message}\n  #{e.backtrace.join("\n  ")}")
  exit(1)
end
