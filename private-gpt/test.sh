#!/bin/bash

set -e
#curl -f -v -H 'Host: private-gpt.local' http://127.0.0.1/

cd test.js && npm install && npm test
