#!/usr/bin/env bash

VERSION=$1
WORKSPACE=$2

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# bundler execution recommended this

echo "setup..."
sudo git config --global --add safe.directory ${WORKSPACE}

# rspec will be looking for this
mkdir -p log
touch log/dataduck.log

# this delete is not working for some reason
sudo rm -f "${WORKSPACE}/datatuck-*.gem"

ls -la

sudo apt-get install ruby-rspec-core ruby ruby-dev libmysqlclient-dev libpq-dev -y
sudo gem install bundler:2.3.26
sudo bundle install

echo "test..."
sudo bundle exec rspec
resie=${?}
echo $resie
if [[ $resie != 0 ]]; then
  exit 1
fi

cat log/dataduck.log

echo "build..."
sudo gem build dataduck.gemspec

sudo chmod 666 dataduck-${VERSION}.gem

ls -la
