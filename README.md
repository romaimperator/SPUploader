SPUploader
==========

These scripts are a templating system that I am using for my senior project
website. There is support for uploading to a remote server using sftp as well.

Installation
------------

SPUploader requires the Net SSH and Net SFTP gems. These can be installed using:

    $ gem install net-ssh net-sftp

To get a copy of SPUploader just clone the repository.

    $ git clone git://github.com/romaimperator/SPUploader.git
    $ cd SPUploader

There you can create your own templates and site build script or check out the
examples provided.

Usage
-----

The example_site_script.rb provides an example of a site build script that uses
two pages. It also uses a generator to provide extra control over what goes into
the final pages.
