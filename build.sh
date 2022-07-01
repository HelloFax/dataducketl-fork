#!/usr/bin/env bash

VERSION=$1
WORKSPACE=$2

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
sudo rm -f datatuck-*.gem
# bundler execution recommended this
sudo git config --global --add safe.directory ${WORKSPACE}

ls -la

sudo apt-get install ruby-rspec-core ruby ruby-dev libmysqlclient-dev libpq-dev -y
sudo gem install bundler
sudo bundle install

# rspec will be looking for this
echo "make logs dir"
mkdir -p log
touch log/dataduck.log

echo "exec spec"
sudo bundle exec rspec
resie=${?}
echo $resie
if [[ $resie != 0 ]]; then
  exit 1
fi

cat log/dataduck.log

echo "build"
sudo gem build dataduck.gemspec

sudo chmod 666 dataduck-${VERSION}.gem

ls -la
