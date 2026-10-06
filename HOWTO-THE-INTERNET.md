It finally happened. The test site I have been using for the past few years, Dave Haefner's The-Internet, hosted on Herokapp, is now failing 50% of the time. 

* The-Internet: https://the-internet.herokuapp.com/

Since the source code, https://github.com/saucelabs/the-internet has an Apache License 2.0 and the MIT License, developers have permission to create their version of the app and modify it. 

* See Sauce Labs [Open Source Licensing Guide](https://opensource.saucelabs.com/docs/license-guide/)

## Copy the source code:
* Log into GitLab, and select "Fork". (See [GitHub Docs / Fork a Repo](https://docs.github.com/en/pull-requests/how-tos/work-with-forks/fork-a-repo). This created https://github.com/tjmaher/the-internet

## Change Default branch: MASTER -> MAIN

* Change MASTER to MAIN: `git branch -m master main` 
* Select "Sync Fork" to update the branch. You can see that "main" is the most updated branch. 
* Go to GitHub Settings --> Default Branch and switch it from "master" to "main". 

## Gemfile Updates
* The Gemfile needs updating:

```source 'https://rubygems.org'
ruby '2.2.5'
```

According to Google AI:
* Replace gem 'shotgun' with gem 'rerun': "Shotgun relies on an aggressive forking mechanism that is completely broken and unmaintained on Ruby 3.x+. Replacing it with the rerun gem in your development group gives you seamless code reloading without the crashes".
* Remove gem 'compass': "The Compass framework was officially deprecated years ago and does not support modern Sass compilation or modern versions of Ruby"
* Remove gem 'uuid': "This gem is redundant. Modern Ruby provides cryptographically secure UUID generation out of the box in its standard library. You can safely delete this gem and use SecureRandom.uuid in your application without requiring any external packages".

### Upgrade Test Environment Locks:
* selenium-webdriver ~> "3.4.0 is severely outdated and will fail to communicate with modern versions of Chrome, Firefox, and Safari. Moving to ~> 4.0 is required".
* rspec ~> "3.5.0 will throw a massive amount of keyword argument deprecation warnings on Ruby 3.2. Upgrading to ~> 3.13 ensures smooth, clean test outputs".

Google AI says: "Both Shotgun and Rerun are Ruby gems designed to solve the exact same headache: automatically reloading your application when you make changes to your code during development

"Rerun is a highly efficient filesystem watcher.
* "How it works: Instead of doing anything fancy inside the Ruby process itself, Rerun simply sits in your terminal and watches the folder you are working in. The moment you save a file (like a .rb, .erb, or .json file), Rerun intercepts the change, uses standard Unix signals (SIGINT/SIGKILL) to cleanly kill your web server, and immediately boots it back up in a fraction of a second". [Ubunto Man Pages / Rerun](https://manpages.ubuntu.com/manpages/jammy/man1/rerun.1.html)

## Setup RENDER, New Hosting Platform

This fork of The-Internet will be on Render.

* https://dashboard.render.com/register

* Signed up for a Render account using GitHub Account. 
* Selected to host a Web Service. 
* Connected to code repositories in GitHub. 
* Chose to install Render on tmaher1/the-internet. 

Render pre-filled: 
* the name to "the-internet", the language to be "Docker", the branch to be "main". 
* Chose the free tier, using .01 CPUs and 512 MB RAM. Free instances spin down after a period of activity.
* Selected "Deploy web service".  

... And it failed. Which is fine. Since it was still the older version running. 

## Test The-Internet Locally

* Delete the old Gemfile.lock file. 
* Run: bundle install

Start the webservice:
* bundle exec rackup --host 0.0.0.0 -p 5000

Connect to the webservice on your local machine:
* http://localhost:5000/

... And, yes, you can see The-Internet!

* http://localhost:5000/login/

... And yes, you can see the Login Page, and Login to the Secure Area using tomsmith / SuperSecretPassword! And you can log out again!

Stop the webservice:
* CNTRL + C

## Add a RENDER.YAML

```services:
  - type: web
    name: the-internet-modern
    env: ruby
    buildCommand: |
      bundle config set --local without "development test"
      bundle install
    startCommand: bundle exec rackup -p $PORT -o 0.0.0.0
    envVars:
      - key: RUBY_VERSION
        value: "3.4.2"
```

## Push the Code

* git status
* git add .
* git commit -m "Upgrade project to Ruby 3.4 and modernize Dockerfile for Render deployment"
* git remote set-url origin https://github.com/tjmaher/the-internet
* git push -u origin main

## Fix Sinatra problems

Going to https://the-internet-8uaj.onrender.com/ showed:

`Host not permitted`

Google AI said that:

"Starting with version 4.1.0, Sinatra introduced strict, built-in security middleware called Rack::Protection::HostAuthorization. By default, this middleware blocks HTTP requests unless the accessing URL matches an allowed list (typically defaulting only to localhost). When Render routes traffic to your app through the-internet-8uaj.onrender.com, Sinatra flags it as an unrecognized hostname and throws a 403 Forbidden response with the body text 'Host not permitted'"


server.rb
```class Protected < Sinatra::Base
  set :host_authorization, permitted_hosts: []
  register Sinatra::Flash
```
## Change Name of Render Web Service

Who would have thought that a name like "the-internet" would be so common?

Render adds a random four characters on a webservice with a common name. 

I decided to make the web address: the-internet-tjmaher.onrender.com