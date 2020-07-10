require 'beaneater'
require 'eventmachine'
require 'json'
require 'logger'
require 'socket'


$loggertimestamp = "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}:"

def beanstalk

    $beanstalk = Beaneater.new(['localhost:11300'])

    while true do

        begin

            STDOUT.puts "#{$loggertimestamp} [INFO] Checking for new Jobs\n"

            $beanstalk.tubes.watch!('updates')

            job = $beanstalk.tubes.reserve(30)
            job_json = JSON.parse(job.body)
            
            STDOUT.puts "#{$loggertimestamp} [INFO] Job Received"

            IO.popen(
                "bolt command run '/usr/bin/r10k \
                --config /etc/puppetlabs/r10k/r10k.yaml deploy environment #{job_json['branch']} \
                -p -v' --no-host-key-check --target puppetmasters -i /worker/inventory.yaml"
                ).each do |p|
                STDOUT.puts p
            end

            job.delete

            STDOUT.puts "#{$loggertimestamp} [INFO]: Job Deleted\n"        

        rescue Beaneater::TimedOutError

            STDOUT.puts "#{$loggertimestamp} [INFO]: No Jobs found, re-running loop\n"

        rescue StandardError => e

            STDERR.puts "#{loggertimestamp} [ERR]: #{e}\n"

            exit 1

        end
    end
end

EventMachine::run do
    Thread.new do
        beanstalk        
    end
end
