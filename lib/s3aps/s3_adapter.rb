require 'rubygems'
require 'right_aws'

module S3aps

  # Reads, writes and lists files on S3.
  class S3Adapter
    
    def initialize(options)
      @s3 = RightAws::S3Interface.new(options[:key], options[:secret], :protocol => 'http', :port => 80)
      @bucket_name = options[:bucket]
    end
    
    # List the keys of all files in the bucket
    def list
      keys = []
      @s3.incrementally_list_bucket(@bucket_name) {|key_set|
        keys << key_set[:contents].map {|key|
          key
        }
      }
      keys.flatten
    end
    
    # Write a value, potentially overwriting what is already there.
    def write(s3_name, value)
      @s3.put(@bucket_name, s3_name, value)
    end
    
    def read(key)
      begin
        @s3.get_object(@bucket_name, key)
      rescue 
        raise exc
      end
    end

  end

end
