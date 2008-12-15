module AWS
  module S3
    module Rake
      class Utils
        class << self
	  include ActionView::Helpers::NumberHelper
          
          def print_bucket(bucket)
            entries = retrieve_all_entries(bucket)
            str = "#{bucket.name} Bucket "
            if bucket.size < 1
              str += 'is empty'
            else
              str += "contains #{entries.size} entries"
            end
            msg str

            key_width = entries.collect{|e| e[:key]}.collect{|n| n.length}.max
            size_width = entries.collect{|e| e[:print_size]}.collect{|n| n.length}.max
            
            entries.each do |e| 
              puts "size: #{e[:print_size].rjust(size_width)}    Key: #{e[:key].ljust(key_width)}    Last Modified: #{e[:modified]} UTC"
            end
          end
          
          def msg(text)
            puts "   #{text}"
          end
          
          def print_size(entry)
	    number_to_human_size(entry.size)
          end
          
          def print_bucket_size(entries)
	    include ActionView::Helpers::NumberHelper
            number_to_human_size(entries.sum{|e| e[:size]})
          end
          
          def retrieve_all_entries(bucket)
            entries = []
            last_key = ''
            while(true)
              old_count = entries.size
              bucket.objects(:marker => last_key).map do |entry| 
                entries << {
                            :size => entry.size,
                            :print_size => print_size(entry),
                            :key => entry.key,
                            :modified => entry.last_modified.to_s(:short)
                           }              
              end
              break if old_count == entries.size
              last_key = entries.last[:key]
            end
            entries
          end
          
          # programatically figure out what to call the backup bucket and 
          # the archive files.  Is there another way to do this?
          def project_name
            # using Dir.pwd will return something like: 
            #   /var/www/apps/staging.sweetspot.dm/releases/20061006155448
            # instead of
            # /var/www/apps/staging.sweetspot.dm/current
            # pwd = ENV['PWD'] || Dir.pwd
            # #another hack..ugh.  If using standard capistrano setup, pwd will be the 'current' symlink.
            # pwd = File.dirname(pwd) if File.symlink?(pwd)
            # File.basename(pwd)
            #UPDATE shifting to use a combination of user and env.... 
            "#{ENV['USER']}_#{ENV['RAILS_ENV']}"
          end
        end
      end
    end
  end
end
