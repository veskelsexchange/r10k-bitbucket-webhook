# r10k-bitbucket-webhook
## Summary
This is an r10k Webhook for Bitbucket Cloud. There are tons of webhooks out there supporting Bitbucket Server or GitLab and Github. I have yet to find one that provides this funtionality.

##  What does this do?
It is a simple service that provides a valid API endpoint for Bitbucket Cloud webhook. The middleware builds a job from the message sent by Bitbucket, a worker then picks the information up and runs a puppet bolt command against an inventory list of your puppetmasters.

## System Requirements
You'll need at least one puppetmaster with SSH access (by default) enabled to it. This service can be run on the same machine as a puppetmaster or on a remote server. To run this system you'll need the following

### Using Docker
You'll need a working docker install. I recommend this option as it lowers the amount of dependencies you'll need installed on the host machine.
Install Docker using the recommended installation methods described at https://docs.docker.com/engine/install/

NOTE: If running in production, you can opt to connect an NGINX or Apache container to it for production hosting and HTTPS support, or you can install the software on the host machine.

### Using the Host machine
This system has been exclusively tested with Docker, however the image used to run it (ruby:2.5) as of this README, uses Debian 10 (Buster). Therefore I can reasonably assume it will run just fine. The software required are as follows

ruby >= 2.5 

ruby-gems 

bundler

puppet-bolt (NOTE: Please see https://puppet.com/docs/bolt/latest/bolt_installing.html for installation instructions)

Gems required can be installed by opening the $PROJECT_ROOT/docker/gems folder in a terminal and running `bundle install`

## Getting started

Getting setup is relatively easy, especially if you opt to use Docker. These directions will assume that you are as it will be much easier to bootstrap this system. The following steps should get you up and running quickly.

1. Clone the repository in your desired working directory (will be referenced as $PROJECT_ROOT) with the following command`git clone https://github.com/jrau9115/r10k-bitbucket-webhook.git`

2. cd into $PROJECT_ROOT and modify the inventory.yaml, adding your puppet masters to the list of targets. Add any other relevant information for bolt to use when run command is fired. (See the following documentation for more information on Bolt Inventory Files https://puppet.com/docs/bolt/latest/inventory_file_v2.html)

3. cd into $PROJECT_ROOT/docker and edit the docker-compose.yaml, making the desired/necessary modifications to meet your environment's needs. Please pay special attention to the `environment` portion of the file. You'll want to modify this to match your desired settings. (Futher info: see https://docs.docker.com/compose/reference/overview/)

4. cd into $PROJECT_ROOT/scripts/ and `run container_services.sh start` (This will build the image and run `docker-compose up -d`). Please make sure you copy the public portion of the SSH Key the system generates (Unless you mount in your own by adding a volume mount in step 3). You'll need to make sure that *ALL* puppet masters you wish to control have this key placed in the appropriate user's (defaults to root) .ssh/authorized_keys file. 

5. Once the system tells you it is running, you should be able to see the application listening on port 3000 (check with `ss -tulpn | grep '3000'`). By default the system listens on localhost for testing. To make sure your system is reachable by the Bitbucket servers, make sure it is listening on either 0.0.0.0 or a publicly accessible interface.

6. You'll want to make sure you have a reverse proxy with HTTPS enabled for maximum security. By default the web server does *NOT* run with HTTPS enabled, this can be changed by you but I don't recommend running a production server with just the exposed puma server.

7. At this point you'll want to login to your bitbucket account and navigate to your control repo for Puppet. In settings, navigate to webhooks and make a new webhook that points at your web server (NOTE: see security concerns and recommendations for further notes and reading) by specifying the URL (i.e. http://r10kbitbucketwebhook.example.com:3000/payload). By default the `/payload` URL suffix is provided for consuming the POST request from Bitbucket. Feel free to change this in web.rb if you prefer something else.


## Security Concerns and Recommendations

Atlassian (at the time of this writing) has designed webhooks that are painfully lacking in security and identity verification for their Cloud platform. Their current recommendation (you can find it here: https://support.atlassian.com/bitbucket-cloud/docs/manage-webhooks/ under the Secure Webhooks) is to use an IP whitelist to control what systems have access to contact your API.

While I certainly have gripes about this method of 'security', I don't really have any other option at this particular point in time. Until they design a better interface, please secure your api server (via Corporate firewall, router, or iptables) by only allowing IPs from the list here: https://ip-ranges.atlassian.com/ (NOTE: Ignore IPv6 if you're not currently using it). I opted not to attach a list in this repo as their IP address ranges/subnets could change in the future and I'm not in the business of keeping a list up to date when they provide one.

Finally, I know I've specified it multiple multiple times but I can't recommend it enough. Use a VALID, SIGNED, SSL cert/key pair and a reverse proxy, *especially* for production servers. The amount of potentially sensitive data Atlassian will send to this API makes the extra work involved worth it. Allowing Atlassian to send that information over PLAIN HTTP IS NOT RECOMMENDED and I won't be held responsible for any compromised systems/transmissions as a result (I'm not liable regardless, see license, but I wanted to state it again here).
