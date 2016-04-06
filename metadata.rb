name             'flashcards-cookbook'
maintainer       'Ilya Dolgirev'
maintainer_email 'ilya.dolgirev@gmail.com'
license          'All rights reserved'
description      'Installs/Configures flashcards mkdev.me course app'
long_description 'Installs/Configures flashcards mkdev.me course app'
version          '0.1.0'

depends 'build-essential'
depends 'user'
depends "ruby_build"
depends 'postgresql'
depends 'database'
depends 'redisio'
depends 'java'
depends 'elasticsearch'
depends 'chef-sugar'
depends 'simple-kibana'
depends 'nginx', '~> 2.7.6'
depends 'htpasswd'
depends 'imagemagick'
depends 'chef-vault'

