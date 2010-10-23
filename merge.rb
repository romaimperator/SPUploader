#!/usr/bin/ruby -w

require 'rubygems'
require 'net/ssh'
require 'net/sftp'
require 'find'
require 'script_constants'

def get_files_in_directory_list(directoryNames)
  filenames = []
  directoryNames.each do |direct|
    Dir.new(direct).each do |fname|
      if (fname != "." && fname != ".." && File.file?(direct + fname))
        filenames.push(direct + fname)
      end
    end
  end
  return filenames
end

def fullPath(fname)
  return File.expand_path(fname)
end


# Returns the HTML of a link given a file with full path and the text to show 
#  on the link
def createLink(file, text)
  return "<a href=\"" + file + "\" target=\"_blank\">" + text + "</a>"
end

def buildNavDiv
  latest = get_files_in_directory_list(Dir['Latest/**/'].sort)
  all = get_files_in_directory_list(Dir['All/**/'].sort)
  reviews = get_files_in_directory_list(Dir['Reviews/**/'].sort)
  
  output = ["<div id=\"right\">\n\t<ul>\nLatest<br />"]
  latest.each do |l|
    (File.expand_path(l)).match(DIR_REGEX)
    output.push("\t\t<li>" + createLink(l, $2) + "</li>\n")
  end
      
  output.push("\t\t<br />Reviews<br />")
  reviews.each do |r|
    (File.expand_path(r)).match(DIR_REGEX)
    output.push("\t\t<li>#{createLink(r, $2)}</li>\n")
  end
  
  output.push("\t\t<br />All Versions<br />")
  all = all.sort
  lastpath = ""
  all.each do |a|
    (File.expand_path(a)).match(DIR_REGEX)
    if lastpath != $2
      lastpath = $2
      output.push("\t\t#{$2}<br />\n")
    end
      
    output.push("\t\t<li> #{createLink(a, File.basename(a))} </li>\n")
  end
  
  output.push("\t</ul>\n</div><!--\/right-->")
  return output.join
end

def buildTable(filename)
  lines = []
  open("table.csv", 'r') { |f| lines = f.readlines }
  filename.match(FILENAME_PATTERN)
  name = $1
  name.capitalize!
  
  output = ["<div id=\"time_table\"><table>\n"]
  output.push("\t<tr>\n\t\t<td>Date</td>\n\t\t<td>Length (min)</td>\n\t\t<td>Members Present</td>\n\t\t<td>Results</td>\n\t</tr>\n")
  lines.each do |l|
    date, len, peeps, done = l.split(';')
    if (peeps.include?(name))
      output.push("\t<tr>\n\t\t<td>" + date + "</td>\n\t\t<td>" + len + \
          "</td>\n\t\t<td>" + peeps + "</td>\n\t\t<td>" + done.chop + \
          "</td>\n\t</tr>\n")
    end
  end
  output.push("</table></div><!--/timetable-->")
  return output.join  
end

def buildBlogPosts
  lines = []
  open("blog.csv", 'r') { |f| lines = f.readlines }
  output = ["<div id=\"blog\">\n"]
  lines.each do |l|
    header, entry = l.split(';')
    output.push("\t<div class=\"blogentry\">\n\t\t<h3>" + header + "</h3>\n" + \
        entry.chop + "\n\t</div>\n")
  end
  output.push("</div><!--\/blog-->")
  return output.join
end


def mergeWithTemplate(filename)
  puts "Processing : " + filename
  
  filename.match(FILENAME_PATTERN)
  name = $1
  
  lines = []
  open("template.part", 'r') { |file| lines = file.readlines }

  lines = lines.join("<line>")
  lines = lines.gsub(/\n/, "<newline>")
  
  TAGS.each do |t|
    if (s = getMatchFromFile(filename, t))
      lines = lines.gsub(t, s)
    end
  end
  if (name != "index" && s = getMatchFromString(buildTable(filename), TABLE_TAG))
    lines = lines.gsub(TABLE_TAG, s)
  end
  if (name == "index" && s = getMatchFromString(buildBlogPosts(), BLOG_TAG))
    lines = lines.gsub(BLOG_TAG, s)
  end
      
  s = getMatchFromString(buildNavDiv, FILE_NAV)
  lines = lines.gsub(FILE_NAV, s)
  
  lines = lines.gsub(/<newline>/, "\n")
  lines = lines.split("<line>")
  
  existlines = []
  open(name + '.html', 'r') { |f| existlines = f.readlines }
  if existlines.join != lines.join
    outfile = open(name + ".html", 'w')
    outfile.write(lines)
    outfile.close()
    uploadFile(name + ".html")
  end
end

def getMatchFromString(string, r)
  string = string.gsub("\n", "<newline>")
  if (string.match(r))
    return $1
  end
end

def getMatchFromFile(filename, r)
  lines = []
  open(filename, 'r') { |f| lines = f.readlines }
  lines = lines.join
  return getMatchFromString(lines, r)
end

def writeStringToRemoteFile(filename, string)
  Net::SFTP.start(HOSTNAME, USERNAME, :password => PASSWORD) do |sftp|
    file_perm = 0644
    remote_path = 'sp/website/'
    begin
      file = sftp.open!(remote_path + filename, 'w')
    rescue Net::SFTP::StatusException => e
      raise unless e.code == 2
      puts 'Error: file #{filename} on remote server'
      next
    end
    
    sftp.write!(file, 0,string)
    sftp.close!(file)
  end
end

def uploadFile(file)
  Net::SFTP.start(HOSTNAME, USERNAME, :password => PASSWORD) do |sftp|
    f = file
    file_perm = 0644
    remote_path = "sp/website"
    next if f.include?('.part') or f.include?('.table') or f.include?('.sh') or f.include?('.rb') or f.include?('.csv') or File.stat(f).directory?
    local_file = "#{f}"
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
    
    puts File.stat(local_file).mtime 
    puts Time.at(rstat.mtime)
    if File.stat(local_file).mtime > Time.at(rstat.mtime + SERVER_TIME_OFFSET)
      puts "Updating #{local_file} to #{remote_file}"
      sftp.upload(local_file, remote_file)
    end
  end
end

def uploadDirectory(dir)
  Net::SFTP.start(HOSTNAME, USERNAME, :password => PASSWORD) do |sftp|
    dir_perm = 0755
    file_perm = 0644
    remote_path = "sp/website"
    Find.find(dir) do |f|
      next if f.include?('.part') or f.include?('.table') or f.include?('.sh') or f.include?('.rb') or f.include?('.csv')
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
      local_file = "#{f}"
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

pages = ["index.part", "dan.part", "brett.part", "matt.part", "marc.part", "about_us.part"]

pages.each do |p|
  mergeWithTemplate(p)
end

uploadFile('index.css')

puts 'Checking latest...'
uploadDirectory("Latest")
puts 'Checking all...'
uploadDirectory("All")
puts 'Checking reviews...'
uploadDirectory("Reviews")
puts 'Finished'
