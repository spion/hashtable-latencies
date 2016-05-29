for program in `cat programs.txt`
do
  cd $program
  echo "Building $program..."
  ./build.sh
  echo "Running $program..."
  run=`cat ./run.sh`
  $run &
  pid=$!
  sleep 3
  echo "Warming up $program..."
  wrk2 --latency -c 33  -t 3 -d 30 -R10000 'http://localhost:8080'
  echo "Generating program report (33 clients)"
  wrk2 --latency -c 33  -t 3 -d 60 -R10000 'http://localhost:8080' > "../reports/033-$program.txt"
  echo "Generating program report (333 clients)"
  wrk2 --latency -c 333 -t 3 -d 60 -R10000 'http://localhost:8080' > "../reports/333-$program.txt"
  kill -s HUP $pid
  sleep 3
  cd ..
done
