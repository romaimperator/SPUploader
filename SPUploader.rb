$LOAD_PATH << './SPUploader'
require 'Site'
#require 'SftpUploader' # Unsure if this needs to be required or not since it
                        # worked without it. It must be included somewhere else
                        # already.
require 'SSVGenerator'

# This file just loads all of the needed class files for the user at once so
#  he/she only needs a single require statement.
