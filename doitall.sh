#!/bin/bash
set -e
set -o pipefail

./000-prereq.sh
./010-container-registry.sh
./020-create-cluster.sh
./025-create-resources.sh
./030-test.sh
./040-cleanup.sh
