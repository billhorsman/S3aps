module S3aps

  # Reads, writes and lists files on the filesystem.
  class FileAdapter
    
    # Options:
    #
    # * :path - where the local files are (default is +tmp+)
    def initialize(options = {})
      @path = options[:path] || "tmp"
    end
    
    # List all the files in the path, recursively
    def list
      Dir.glob("#{@path}/**/*").select{|path| File.file?(path) }.map do |path|
        path.sub Regexp.new("^#{@path}\/"), ''
      end
    end
    
    # Write the file. It will always write the file whether it's there
    # or not, unless you supply an +md5sum+ in which case it will check
    # whether it's different first.
    def write(path, value, md5sum = nil)
		  just_path = path.sub /\/[^\/]*$/, ''
		  local_md5 = md5sum(path)
		  if local_md5.nil? || local_md5 != md5sum
  		  FileUtils.mkdir_p(File.join(@path, just_path))
        File.open(File.join(@path, path), 'w') {|outfile| 
          outfile.print(value)
        }
        true
      else
        false
      end
    end
    
    # Read the file.
    def read(path)
      File.open(File.join(@path, path),"rb") {|io| io.read}
    end
    
    def md5sum(path) #:nodoc:
      md5 = nil
      begin
        md5 = File.open(File.join(@path, path), 'rb') do |io|
          d = Digest::MD5.new
          s = ""
          d.update(s) while io.read(4096, s)
          d
        end
      rescue
      end
      md5 ? md5.to_s : nil
    end
    
  end
  
end