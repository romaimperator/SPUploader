require 'rubygems'
require 'net/sftp'
require 'find'

# This module contains functions for uploading the pages to a remote site.
#
# It requires the following constants to be declared to work:
#   HOSTNAME - the hostname of the server
#   USERNAME - your username to login with
#   PASSWORD - your password

module SftpUploader  
  # This function writes the 'string' to the file of name 'filename' to the
  #  'remote_path'.
  def write_string_to_remote_file(filename, string, remote_path)
    Net::SFTP.start(HOSTNAME, USERNAME, :password => PASSWORD) do |sftp|
      file_perm = 0644
      begin
        file = sftp.open!(remote_path + filename, 'w')
      rescue Net::SFTP::StatusException => e
        raise unless e.code == 2
        puts 'Error: file #{filename} on remote server'
        next
      end
      
      puts "Writing file #{filename} to #{remote_path}"
      sftp.write!(file, 0, string)
      sftp.close!(file)
    end
  end


  # This function uploads the 'local_file' to the 'remote_path'. It checks if
  #  the file has been modified more recently than the one on the server it will
  #  upload the new version otherwise it does not upload the file.
  def upload_file(local_file, remote_path)
    Net::SFTP.start(HOSTNAME, USERNAME, :password => PASSWORD) do |sftp|
      file_perm = 0644
      next if File.stat(local_file).directory?
      remote_file = remote_path + "/" + local_file
      
      begin
        rstat = sftp.stat!(remote_file)
      rescue Net::SFTP::StatusException => e
        raise unless e.code == 2
        puts "Copying #{local_file} to #{remote_file}"
        sftp.upload(local_file, remote_file)
        sftp.setstat(remote_file, :permissions => file_perm)
        next
      end
      
      #puts File.stat(local_file).mtime 
      #puts Time.at(rstat.mtime)
      if File.stat(local_file).mtime > Time.at(rstat.mtime)
        puts "Updating #{local_file} to #{remote_file}"
        sftp.upload(local_file, remote_file)
      end
    end
  end
  
  # This function uploads the 'local_dir' to the 'remote_path'. It recursively
  #  searches through the folder and checks every file. If the file has been
  #  modified more recently than the one on the server it will upload the new
  #  version. If a directory does not exist, it is created.
  def upload_directory(local_dir, remote_path)
    Net::SFTP.start(HOSTNAME, USERNAME, :password => PASSWORD) do |sftp|
      dir_perm = 0755
      file_perm = 0644
      Find.find(local_dir) do |f|
        #next if f.include?('.part') or f.include?('.table') or f.include?('.sh') or f.include?('.rb') or f.include?('.csv')
        if File.stat(f).directory?
          begin
            remote_dir = remote_path + "/" + f
            sftp.stat!(remote_dir)
          rescue Net::SFTP::StatusException => e
            raise unless e.code == 2
            puts "Creating remote directory #{remote_dir}"
            sftp.mkdir(remote_dir, :permissions => dir_perm)
          end
          next
        end
        local_file = f
        remote_file = remote_path + "/" + local_file
        
        begin
          remote_dir = File.dirname(remote_file)
          sftp.stat!(remote_dir)
        rescue Net::SFTP::StatusException => e
          raise unless e.code == 2
          puts "Creating remote directory #{remote_dir}"
          sftp.mkdir(remote_dir, :permissions => dir_perm)
        end
        
        begin
          rstat = sftp.stat!(remote_file)
        rescue Net::SFTP::StatusException => e
          raise unless e.code == 2
          puts "Copying #{local_file} to #{remote_file}"
          sftp.upload(local_file, remote_file)
          sftp.setstat(remote_file, :permissions => file_perm)
          next
        end
        
        if File.stat(local_file).mtime > Time.at(rstat.mtime + SERVER_TIME_OFFSET)
          puts "Updating #{local_file} to #{remote_file}"
          sftp.upload(local_file, remote_file)
        end
      end
    end
  end
end
