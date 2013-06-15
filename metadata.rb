name             'cellar'
maintainer       'trajar'
maintainer_email 'https://github.com/trajar/cellar'
license          'Apache 2.0'
description      'LWRPs for managing aws-s3 backups'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
recipe           'cellar', 'Installs aws-s3 gems and LWRPs'