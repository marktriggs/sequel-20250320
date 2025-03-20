#!/bin/bash

jruby_url="https://repo1.maven.org/maven2/org/jruby/jruby-complete/9.4.12.0/jruby-complete-9.4.12.0.jar"
jruby_sha256="afb903dc9d38843fed4961cdb63489a78d1b1783f5766acb5bc89f5fc720ed21"

set -eou pipefail

cd "`dirname "$0"`"

if [ ! -e lib/bootstrapped.txt ]; then
    rm -rf lib; mkdir -p lib

    (
        cd lib

        echo "Fetching JRuby..."
        curl -L -s "$jruby_url" > jruby-complete.jar
        checksum="`openssl dgst -sha256 jruby-complete.jar | awk '{print $2}'`"

        if [ "$checksum" != "$jruby_sha256" ]; then
            echo "JRuby checksum mismatch.  Aborting."
            exit 1
        fi
    )

    mkdir lib/gems
    GEM_HOME="$PWD/lib/gems" java -cp 'lib/*' org.jruby.Main -S gem install jdbc-sqlite3

    git clone --depth=1 https://github.com/jeremyevans/sequel.git lib/sequel

    touch lib/bootstrapped.txt
fi


set -x
env GEM_HOME="$PWD/lib/gems" java -cp 'lib/*' org.jruby.Main testcase.rb
