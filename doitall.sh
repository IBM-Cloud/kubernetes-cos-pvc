#!/bin/bash
set -e
set -o pipefail

./000-prereq.sh
./010-container-registry.sh
./020-create-resources.sh
./030-test.sh
./040-cleanup.sh

