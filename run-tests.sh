#!/bin/sh
# Copyright 2017 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install NVM
ROOT=`pwd`
cd ~
export NVM_DIR=`pwd`/.nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.4/install.sh | bash

# Load NVM
. $NVM_DIR/nvm.sh

set -ex
cd $ROOT

if [ ! -n "$node_versions" ] ; then
  node_versions="4 5 6 7 8"
fi

# TODO(mlumish): Add electron tests

for version in ${node_versions}
do
  git clean -f -d -x
  # Install and setup node for the version we want.
  set +ex
  echo "Switching to node version $version"
  nvm install $version
  nvm use $version
  set -ex

  # Install dependencies and link packages together.
  npm install
  ./node_modules/.bin/gulp setup

  # Rebuild libraries and run tests.
  ./node_modules/.bin/gulp native.test || FAILED="true"
done

if [ "$FAILED" != "" ]
then
  exit 1
fi