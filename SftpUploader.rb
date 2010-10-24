

module SftpUploader
  #def initialize(hostname, username, password)
  #  @hostname = hostname
  #  @username = username
  #  @password = password
  #end
  
  def writeStringToRemoteFile(filename, string, remote_path)
    Net::SFTP.start(HOSTNAME, USERNAME, :password => PASSWORD) do |sftp|
      file_perm = 0644
      begin
        file = sftp.open!(remote_path + filename, 'w')
      rescue Net::SFTP::StatusException => e
        raise unless e.code == 2
        puts 'Error: file #{filename} on remote server'
        next
      end
      
      sftp.write!(file, 0, string)
      sftp.close!(file)
    end
  end


  def uploadFile(local_file, remote_path)
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
  

  def uploadDirectory(local_dir, remote_path)
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
