require 's3aps/file_adapter'
require 's3aps/s3_adapter'
require 'yaml'

module S3aps
  
  def self.symbolize_keys(hash) #:nodoc:
    new_hash = {}
    hash.each do |key, value|
      if Hash === value
        new_hash[key.to_sym] = symbolize_keys value
      else
        new_hash[key.to_sym] = value
      end
    end
    new_hash
  end

  # The controller for everything else. 
  class Sync
    
    def initialize(options = {})
      options = S3aps::symbolize_keys(options)
      s3_file = [options[:config], "s3.yml", "config/s3.yml"].detect {|f| f && File.file?(f) }
      if s3_file
        puts "Configuring S3 from #{s3_file}"
        yaml_options = S3aps::symbolize_keys YAML.load_file(s3_file)
        env = options[:env]
        if env && yaml_options[env.to_sym]
          yaml_options = S3aps::symbolize_keys yaml_options[env.to_sym]
          puts "Using #{env} environment"
        end
        # Support for alias: access_key_id = key 
        if yaml_options[:access_key_id]
          yaml_options[:key] ||= yaml_options[:access_key_id]
          yaml_options.delete(:access_key_id)
        end
        # Support for alias: secret_access_key = secret 
        if yaml_options[:secret_access_key]
          yaml_options[:secret] ||= yaml_options[:secret_access_key]
          yaml_options.delete(:secret_access_key)
        end
        options.merge!(yaml_options) {|k,o,n| o }
      end
      @s3_adapter = S3aps::S3Adapter.new options
      @file_adapter = S3aps::FileAdapter.new options
    end
    
    # Merge the local and remote lists into one and indicate whether
    # each item is local, remote or both
    def list
      local = @file_adapter.list 
      remote = @s3_adapter.list.map{|i| i[:key]}
      all = (local + remote).uniq.sort
      all.map do |path|
        [
          local.include?(path) ? "L" : " ",
          remote.include?(path) ? "R" : " ",
          path
        ]
      end
    end
    
    # Get all the remote files and write them out locally, if they don't already
    # exist. For simplicity, we assume that if a file of the same name already
    # exists then it is the same as the remote one. 
    def pull
      check_list = @file_adapter.list
      count = 0
      total = 0
  		@s3_adapter.list.each do |o|
        if !check_list.include?(o[:key])
          $stdout.print "*"
  		    if @file_adapter.write(o[:key], @s3_adapter.read(o[:key]), o[:etag])
  		      count += 1
		      end
		    else
          $stdout.print "."
		    end
        $stdout.flush
        total += 1
		  end
    [count, total]
    end
    
    # Get all the local files, recursively, and write them to S3, if they don't already
    # exist. For simplicity, we assume that if a file of the same name already
    # exists then it is the same as the local one. 
    def push
      check_list = @s3_adapter.list.map{|i| i[:key]}
      count = 0
      total = 0
      @file_adapter.list.each do |path|
        if !check_list.include?(path)
          $stdout.print "*"
          if @s3_adapter.write(path, @file_adapter.read(path))
            count += 1
          end
		    else
          $stdout.print "."
        end
        $stdout.flush
        total += 1
      end
      [count, total]
    end 

  end
  
end