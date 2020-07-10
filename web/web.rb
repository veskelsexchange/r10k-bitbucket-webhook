require 'beaneater'
require 'json'
require 'sinatra/base'
require 'sinatra/json'


class BitbucketHook < Sinatra::Application
    
    get '/' do
        json({'response': 'Its Alive!'})
    end

    post '/payload' do
        
        jso = JSON.parse(request.body.read)
        
        begin
            @beanstalk = Beaneater.new(['localhost:11300'])
        
            tube = @beanstalk.tubes["updates"]
        
            job = {:branch => jso['push']['changes'][0]['new']['name']}.to_json
        
            tube.put job
        
            json :response => "Job received.", :code => 200
        
        rescue StandardError => e
           
            json :response => "Error occurred processing order. Message contained: #{e}", :code => 500
        
        ensure

            @beanstalk.close

        end
    end
end
