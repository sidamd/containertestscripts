#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the Chroma test commands for singularity container
#
#To run the script, download the script using wget then:
#       sh ./run_chroma_singularity_tests.sh
#

echo "=== CHROMA Log Collection Utility: V2.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "=== Section: Pull amdih/chroma docker container ======="
singularity pull --docker-login chroma_3.43.0.sif docker://amdih/chroma:3.43.0
echo "=== Pull complete ===="

echo "===== Section: Available ROCm versions ==============="
/bin/ls -v -d /opt/rocm*
ROCM_VERSION=`/bin/ls -v -d /opt/rocm-[3-4]* | /usr/bin/tail -1`
if [ "$ROCM_VERSION"x = "x" ]
then
    ROCM_VERSION=`/bin/ls -v -d /opt/rocm* | /usr/bin/tail -1`
fi
echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "==== Section: Run chroma docker run-benchmark script with --ngpus 1 ========"
singularity run --pwd /benchmark --writable-tmpfs chroma_3.43.0.sif run-benchmark --ngpus 1
echo "=== chroma run-benchmark script complete ===="

echo "==== Section: Run chroma docker run-benchmark script with --ngpus 2 ======"
singularity run --pwd /benchmark --writable-tmpfs chroma_3.43.0.sif run-benchmark --ngpus 2
echo "=== chroma run-benchmark script complete ==="

echo "==== Section: Run chroma docker run-benchmark script with --ngpus 4 ======"
singularity run --pwd /benchmark --writable-tmpfs chroma_3.43.0.sif run-benchmark --ngpus 4
echo "=== chroma run-benchmark script complete ==="

echo "==== Section: Run chroma docker run-benchmark script with --ngpus 8 ======"
singularity run --pwd /benchmark --writable-tmpfs chroma_3.43.0.sif run-benchmark --ngpus 8
echo "=== chroma run-benchmark script complete ==="

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "======== Section: print logs ========"
/bin/dmesg | grep -E 'gpu|pcie' | tail -100
