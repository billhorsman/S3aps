require 'optparse'
require 'fileutils'
require 's3aps/sync'

module S3aps
  
  # Allows you to run S3aps from the command line
  class Runner

  	attr_accessor :argv

  	def initialize(argv)
      @options = {}
      @cmd = :help
      @option_parser = OptionParser.new do |o|
        o.banner = <<EOS
S3aps version #{S3aps::VERSION}
Usage: s3aps (list|pull|push|version) [OPTIONS]

  list  List files locally and remotely
  pull  Pull new files from remote
  push  Push new files to remote (be careful)

EOS
        o.on("-c", "--config FILE", "YAML file containing S3 credentials") {|name| @options[:config] = name }
        o.on("-e", "--env ENV", "Section of YAML to use") {|name| @options[:env] = name }
        o.on("-b", "--bucket NAME", "S3 bucket name") {|name| @options[:bucket] = name }
        o.on("-k", "--key KEY", "S3 access key") {|name| @options[:key] = name }
        o.on("-s", "--secret KEY", "S3 secret key") {|name| @options[:secret] = name }
        o.on("-p", "--path PATH", "Local path") {|name| @options[:path] = name }
        o.parse!(argv)
      end
      if argv.size == 1 && %w(list push pull version).include?(argv.first)
        @sync = S3aps::Sync.new @options 
        @cmd = argv.first
      end
  	end

  	def run #:nodoc:
     send(@cmd)
  	end
  	
  	def help #:nodoc:
  	 puts @option_parser.help
	  end
	  
	  def sync(options) #:nodoc:
	    S3aps::Sync.new options
    end

    # Prints out a list of all remote and local files and shows which ones
    # are remote, local or both.
    def list
      array = @sync.list
      local_count = 0
      remote_count = 0
      array.each do |item|
        line = item.join(' ')
        local_count +=1 if line =~ /^L\s\s/
        remote_count +=1 if line =~ /^\s\sR/
        puts item.join(' ')
      end
      puts "Found #{array.size} file(s): #{local_count} local only, #{remote_count} remote only, #{array.size - local_count - remote_count} common."
    end
  	
    # Pull files from S3
  	def pull
  	  count, total = @sync.pull 
      puts "\nPulled #{count}/#{total} file#{'s' unless count == 1} from S3"
  	end

    # Push files to S3
  	def push
      count, total = @sync.push
      puts "\nPushed #{count} file#{'s' unless count == 1} to S3"
  	end

  	def version #:nodoc:
  		puts S3aps::VERSION
  	end

  end
end
