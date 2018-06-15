#!/bin/bash

cctz=../src/cctz/

rm -rf $cctz
mkdir $cctz
git clone https://github.com/google/cctz.git cctz_tmp
cp -r cctz_tmp/include $cctz/include

LIBCCTZ="tzfile time_zone_fixed time_zone_if time_zone_impl time_zone_info time_zone_libc time_zone_lookup time_zone_posix"
mkdir $cctz/src/

for f in $LIBCCTZ
do
    cp ./cctz_tmp/src/$f* $cctz/src/
done

rm -rf cctz_tmp
