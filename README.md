# mturk-rails
Framework for mturking using ruby on rails

# Simple instructions

## Installation and setup
* Installing ruby on rails (we use ruby 2.5.0, rails 5.1.4):
  * Windows: http://railsinstaller.org/en
  * MacOS: https://gorails.com/setup/osx
  * Ubuntu: https://gorails.com/setup/ubuntu

* Setup config files
  `cp config/example.config.yml config/config.yml`
  `cp config/example.secrets.yml config/secrets.yml`
  
* Setup rails project
  * From command line
    * Run `bundle install` to install dependent gems
    * Run `bundle exec rake db:migrate` to build/update the database (by default uses sqlite3)
    * Run `rails server` to start an instance of the server running at `localhost:3000`.  
    * Test with existing MTurk task `select_item`
       * Run `bundle exec rake mturk:develop[select_item]` 
       * Check `http://localhost:3000/experiments/select_item`
    * To get list of rake tasks
       `rake -D`

  * From Intellij
    * Add Ruby plugin (File -> Settings -> Plugins)
    * Add installed Ruby as SDK (Module settings -> SDKs)
    * Add `rails` as a RubyRails module (Module settings -> Add New Module (Ruby on Rails Module))
    * Run `bundler install` (Tools->Bundler->Install)
    * Run `db:migrate` (Tools->Run Rake Task)
    * Run `Development:rails` (run applications dropdown)
    * Test with existing MTurk task `select_item`
       * Develop the MTurk task: `mturk:develop select_item` (Tools->Run Rake Task)
       * Check `http://localhost:3000/experiments/select_item`

    * Looking at DB from Intellij
      * Add Database Navigator plugin
      * Drag rails/db/development.sqlite3 over to the Database pane (on right - if Intellij didn't create it for you)
      * Double-click on the datasource to install missing drivers
 
    Note: When running rake tasks or the server, make sure that under `Run/Debug Configurations -> Bundler -> Run the script in context of the bundle (bundle exec)` is checked.  Otherwise, you may get:

      rake aborted!
      Gem::LoadError: You have already activated rake 10.4.0, but your Gemfile requires rake 10.1.0. Prepending `bundle exec`      to your command may solve this.

## MTurking

### Creating a MTurk Task
 * This generates various files needed for the mturk task

      `rails generate experiment <name>`  (see `lib/generators/experiments/USAGE`)

### Developing a MTurk Task
 * This creates the necessary tables in the database

     `rake mturk:develop <name>`

### Posting MTurk job (on Linux)
* Configuration notes
 * Update `config/config.yml` and `config/secrets.yml` with secret
 * Modify config to have production/development environment
   * Database - modify `config/database.yml` 
     * For development, we use [sqlite](https://www.sqlite.org/index.html) for storing annotations.  
     * For production, we recommend setting up a database that supports concurrency such as [mysql](https://www.mysql.com/).
 * If testing locally set `HOST_BASE_URL: http://localhost:3000`
   For use with AMT, make sure the `HOST_BASE_URL` starts with `https`
 * Initial bundle install need to have `--deployment` to work properly with Phusion Passenger (for apache)

    `RAILS_ENV=production bundle install --deployment`

* Basic steps for running MTurk task
    ```
    rake db:migrate
    rake mturk:run <name>
    rake mturk:recall <name>
    ```

* Setting Sandbox (deploy to AMT sandbox) vs non-sandbox (real deployment).  
  In `config/initializers/rturk.rb`
     `sandbox: true`

* To run production:
  1. Update assets
  
    `RAILS_ENV=production RAILS_RELATIVE_URL=/mturkrails bundle exec rake assets:precompile`

  2. Submit to AMT:
   
    `RAILS_ENV=production bundle exec rake mturk:run[<name>]`

  3. Dump database after tasks complete:

    `RAILS_ENV=production rake db:data:dump` (look for `db/data.yml`)

  4. Recall from AMT to pay workers and delete task (make sure to dump db before recalling):

    `RAILS_ENV=production bundle exec rake mturk:recall[<name>]`

* Check on AMT:
  * Sandbox: `https://workersandbox.mturk.com`
  * Search by task name or for requester (PH AMT Group)
   

* Restarting server:

    `touch tmp/restart.txt`

# Detailed instructions

## Installation / Setup  (local development)

0. Get Ruby on Rails if not already installed (http://railsinstaller.org/en for Windows, https://gorails.com/setup/osx for Mac OS X, or https://gorails.com/setup/ubuntu for Ubuntu/Linux).  You will also need to install mysql (`brew install mysql` for Mac OS X, through `apt-get` in Linux, etc.).

1. Clone this repository onto your machine

2. Get a copy of the `config/config.yml` file from your teammates or look at the `config/example.config.yml` file for some directions on how to create your own from scratch.  The values in this file are secrets, so you ABSOLUTELY don't want to put this file under version control or make it publicly available. Starting with Rail 4.x, you will also need to have a `config/secrets.yml`.  For development, you can just copy `config/example.secrets.yml` to `config/secrets.yml`.

3. In the `config.yml`, for local development purposes you can leave `HOST_BASE_URL` set to `localhost:3000`.  For running a production instance on MTurk, make sure the `HOST_BASE_URL` starts with `https:` and that you have a proper SSL certificate for your server.

4. Run `bundle install` to get all the ruby gems you need.   If you have problems running `bundle install`, try removing your `Gemfile.lock`, and make sure you have command-line build tools (e.g., Xcode tools) installed (necessary for gems that need to build native extensions).

5. Run `bundle exec rake db:migrate` to build/update the database

6. Run `rails server` to start an instance of the server running at `localhost:3000`.  Point your browser to http://localhost:3000 to visit the app.

## Deployment (Apache + Passenger)
0. Follow steps 1 - 5 as above (more convenient if checkout is through https and into a shared folder such as `/home/shared`)
1. make sure the checked out repository has permissions allowing access by apache process (ensure group ownership is set to `www-pub`)
2. Create symlink in active apache DocumentRoot path (usually `/var/www/`) pointing to the `mturkrails/public` directory
3. install Phusion Passenger: `gem install passenger` ([documentation](http://www.modrails.com/documentation/Users%20guide%20Apache.html))
4. Install passenger module for Apache: `passenger-install-apache2-module` and follow directions to modify apache files
5. Add a block of the following form into the active Apache site virtual host (currently `/etc/apache2/sites-available/default`):

   ```
   RackBaseURI /mturkrails
   RackEnv production
   PassengerAppRoot /path/to/mturkrails/
   <Directory /var/www/mturkrails>
    	Options -MultiViews
   </Directory>
   ```

6. Before running in the production environment, make sure to precompile assets through:

    ```
    RAILS_RELATIVE_URL_ROOT="/mturkrails" bundle exec rake assets:clean
    RAILS_RELATIVE_URL_ROOT="/mturkrails" bundle exec rake assets:precompile
    ```
7. Restart apache server using `sudo service apache2 restart`

## How to create a new Mechanical Turk Experiment/Task and Manage It

The following assumes that we are running in development mode on a local machine.

1. Run `rails generate experiment sampleName` to generate some skeleton files.
   The skeleton files will be usable out of the box, so try that first.

2. Take a look at the generated skeleton and get a feel for what everything
   does.  Make sure to update the `config/experiments/sampleName.yml` with your configuration.

3. Run `bundle exec rake mturk:develop[sampleName]` to create the database entries for the
   experiment and run the setup script. You can develop locally by providing
   a param to the appropriate address (e.g. `mturk/task?assignmentId=xxx&workerId=yyy&hitId=sampleName`  or `experiments/sampleName?task_id=7`)

4. Run `bundle exec rake mturk:run[sampleName]` in order to launch the experiment
   you just created on the MTurk sandbox.

5. Go to the worker sandbox (https://workersandbox.mturk.com/) and try doing your new task. You can switch to posting real HITs by flipping the sandbox boolean in `config/initializers/rturk.rb` -- make sure everything works out before doing this and remember to return back to sandbox mode after finishing with your task.

6. After running a task, you can do `bundle exec rake mturk:recall[sampleName]` to approve all workers 
   and withdraw the task from Amazon Mturk.  WARNING: This will remove all evidence of the
   hit from Amazon as well make it hard to adjust payment for Turkers.  The data tables
   for the task is retains so your results are still there.  For development, you 
   may want to wipe out those tables too.  To do so, you can do `rake mturk:destroy[sampleName]` 
   to completely destroy all evidence of having run the experiment.  WARNING:
   If you do this in production you will lose all your experiment data.
   This is a bad idea, and will make it hard/impossible to audit yourself later.

7. When you're done playing around, make sure to get rid of all these junky
   template files for the `sampleName` task by running
   `rails destroy experiment sampleName`

8. Now go ahead and create an experiment with an actual name!

9. For more experiment management commands run `rake --tasks` or
   look at the `lib/tasks/mturk.rake` file

## Demo Mechanical Turk Tasks

We currently have the following mechanical turk tasks as examples.  You can find which tasks you have in your database by going to `mturk/tasks`.  In production mode, in order to manage the mturk tasks from the web interface, you will need to make sure that you are logged in and that the user's role is "mturk" (you can run `bundle exec rake mturk:allow[user's name]` to give a user access to the mturk role. In development mode, there is a link to test your task.

### select_item
Ask users to select item matching a description

After running task, go to `experiments/select_item/results` to view results.


## Troubleshooting

### Problem setting up a new server
* Error installing nokogiri on Mac OS

  Make sure you have xcode command line tools installed

    xcode-select --install

* Error during `bundle install`.

  Try removing your `Gemfile.lock`
  Also, make sure that you have command-line build tools (e.g., Xcode tools) installed for gems that need to build native extensions

* SSL error during `bundle install`

    Gem::RemoteFetcher::FetchError: SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B 

  Try modifying Gemfile to use http instead of https
    source 'http://rubygems.org'
  See http://railsapps.github.io/openssl-certificate-verify-failed.html 

* Error precompiling assets.

  Check that your ruby version is `ruby-2.0.0`.  
  Use [rvm](https://www.digitalocean.com/community/tutorials/how-to-use-rvm-to-manage-ruby-installations-and-environments-on-a-vps) to manage and install `ruby-2.0.0`.


* You just set up a new server, and everything should be working, but you get "The page you were looking for doesn't exist."

  If you have been testing with a different instance, try a different browser or incognito mode.  You were probably logged in, and the new server doesn't know about that user.  If incognito mode works, create a user and login.
 

## Tools

* http://sqlitebrowser.org/ for viewing/editing Sqlite database 
 
