# This file contains the constants for the upload script


#remote server info
HOSTNAME = ''
USERNAME = ''
PASSWORD = ''

#HTML tags to check for in subfiles and replace in the template
TAGS = [ /(<div id=\"middle\">.*<\/div><!--\/middle-->)/,
         /(<div id=\"leftnav\">.*<\/div><!--\/leftnav-->)/,
         /(<div id=\"right\">.*<\/div><!--\/right-->)/,
         /(<h1 id=\"headline\">.*<\/h1>)/,
         /(<title>.*<\/title>)/,
         /(<head>.*<\/head>)/,
       ]

#These tags are special divs in my individual pages that get replaced
TABLE_TAG = /(<div id=\"time_table\">.*<\/div><!--\/timetable-->)/
BLOG_TAG = /(<div id=\"blog\">.*<\/div><!--\/blog-->)/

#Finds the base name of the file
FILENAME_PATTERN = /(\w+)\.part/

#Finds the parent directory of a file
DIR_REGEX = /([^\/]*?[\/])*([^\/]+?)\/(.*)/
ONLY_DIR = /(.*)\/(.*)/
FILE_NAV = /(<div id=\"right\">.*<\/div><!--\/right-->)/

SERVER_TIME_OFFSET = - 180 * 1000
