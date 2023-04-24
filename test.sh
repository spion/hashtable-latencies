#!/bin/bash

if [ -z "$1" ]
then
  programs=$(cat programs.txt)
else
  programs=$*
fi

runtest() {
  local program="$1"
  echo "Running $program..."
  ./run.sh &
  local pid=$!
  sleep 1
  echo "Warming up $program..."
  wrk2 --latency -c 99 -t 3 -d 60 -R10000 'http://localhost:8080' | head -n17
  echo "Generating $program report..."
  wrk2 --latency -c 99 -t 3 -d 210 -R10000 'http://localhost:8080' > "../reports/$program"
  grep -E '(VmRSS|VmPeak)' /proc/$pid/status
  sleep 1
  kill -9 $pid
  sleep 2
}

for program in $programs
do
  pushd "$program"
  echo "Building $program..."
  ./build.sh
  runtest "$program"
  popd
done
