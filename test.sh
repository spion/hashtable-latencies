if [ -z "$1" ]
then
  programs=`cat programs.txt`
else
  programs=$*
fi

runtest() {
  local program="$1"
  local cmd="$2"
  echo "Running $program..."
  $cmd &
  local pid=$!
  sleep 3
  echo "Warming up $program..."
  wrk2 --latency -c 99 -t 3 -d 60 -R9000 'http://localhost:8080' | head -n17
  echo "Generating $program report..."
  wrk2 --latency -c 99 -t 3 -d 180 -R9000 'http://localhost:8080' > "../reports/$program"
  kill -s HUP $pid
  sleep 3
}

for program in $programs
do
  cd $program
  echo "Building $program..."
  ./build.sh
  run=`cat ./run.sh`
  runtest $program "$run"
  cd ..
done
