About
================================================================================

Deploys project files from a remote server, and configures the project locally.

Default arguments include:

	$project_name = $title,
	$deploy_files = true,
	$remote_websites_dir = "/data/available-websites",
	$remote_host = "compnet-nexus.bu.edu",
	$remote_user = "deploy",
	$deploy_setup = true,
	$local_websites_dir = "/data/websites",
	$project_config_dir = ".config",

Deploy script details
---------------------

The deploy module:

	- Transfers files intelligently from a mix of live-data backups and
	  git repository files.
	- Sets up PHP and Python environments, including `setup.sh` and `setup.sh`
	  scripts.
	- Creates MySQL database, including database creation, user creation,
	  schema checks, and data importing.

Future revisions will include post-install smoke tests and SQLite support.

# Deploying a basic project #

Available projects are stored on the puppet server in the directory
`$remote_websites_dir/$project_name`.

Within this project directory the bare minimum required is a `./files`
directory. Anything within `./files` will be transferred to the project directory on the puppet client.

# Using Git #

The `./files` directory may contain a git repository. The contents of the
`live` branch will be transferred to the puppet client.

The transferred files includes everything except the `.git` directory. Since
target puppet clients are assumed to be disposable virtual machines, a git
repository is not setup on the target puppet client. This ensures all changes
go through the Puppet Master's repository, and preventing accidental data loss
or and minimizing malicious data pushes.

# Continuous Delivery by hooking into Jenkins/Hudson #

By using a git repository for the `./files` directory, it becomes easy to
create a [continuous](http://continuousdelivery.com/)
[delivery](http://www.amazon.com/dp/0321601912) environment. Passing code can
be added to a `deployable` branch, then pushed to the project `./files`
directory.

When a release candidate is ready to be launched, simply merge the `deployable`
branch into `live`. The next time the puppet client is run the new data will be
deployed.

# Separating application code and application data #

Application code and generated data should be stored separately, keeping
code repositories slim and sensitive application data secure.

This module is made to work in tandem with the
[puppet-backup](https://github.com/chrislaskey/puppet-backup) module, making
deployment of separate application code and application data a breeze.

The default `puppet-backup` module adds the `backup` directories, making
the project directory structure look like:

	./files/
	./backup/latest/
	./backup/automated-backup-2013-01-01.tar.gz
	./backup/automated-backup-2012-10-22.tar.gz

Project code is stored inside a git repository in `./files`. Full application
code, data, and database data is inside `./backup/latest`.

# Deploying files #

Simplified, the deployment process is as follows:

- If a `./backup/latest` dir does not exist, transfer the complete contents of
  `./files` and exit
- If a `./backup/latest` dir does exist, transfer the complete contents of the
  dir. Then,
  - If `./files` is a git repository, overwrite any stale backup files with the
  	latest from the repository
  - If `./files` is not a git repository, trust the latest backup is the latest
  	and exit without transfering anything else.

The deploying process ensures the correct files are launched, whether the
project is a simplified `./files` directory only or a git repository with
separated application data and application code.

File transfering is handled with a combination of `git archive` and `rsync`
over `ssh`. See the `templates/deploy-files.sh` for more technical details.

# Project setup #

Once the files are transferred, if the `$deploy_setup` is `true` the module
will attempt to setup the project:

- If there is a `setup.sh` script, it will be executed
- If there is a `setup.py` script, it will be executed

Finally the project setup will look for a `.config` directory. This contains
meta information about the project, including information on how to deploy. It
may contains directories such as:

	./files/.config/
	./files/.config/mysql-appusers/
	./files/.config/mysql-appdata/
	./files/.config/scripts/

The `scripts/` directory functionality is not currently implemented, but in the
future it will be a place for project specific pre-deploy, post-deploy, and
smoke test scripts.

The `mysql-*` directories contain information for the creation of databases,
database users, table schema, and database data.

# Setting up MySQL #

Inside a `.config` directory there may be a `mysql-*` directory for each
database a project requires. One directory should contain the files:

	./files/.config/mysql-appusers/database.sql
	./files/.config/mysql-appusers/name
	./files/.config/mysql-appusers/users.sql
	./files/.config/mysql-appusers/schema.sql
	./files/.config/mysql-appusers/data.sql

**Note:** If there is only one database, then the dir can simply be called
`mysql`.

The `name` file should contain one line, the name of the database. The
`users.sql` and `database.sql` should create the database and users.

If a `data.sql` file exists it will be executed, creating both the table
structure and insert application data. If a `data.sql` file does not exist,
then `schema.sql` will be loaded creating the table structure, but inserting no
data. Both `data.sql` and `schema.sql` should be idempotent, utilizing `IF NOT
EXISTS` statements on every insert/create query. (if using the `puppet`)

**Note:** If using the
[puppet-backup](https://github.com/chrislaskey/puppet-backup) module, an
appropriate `data.sql` file will be autogenerated.

License
================================================================================

All code written by me is released under MIT license. See the attached
license.txt file for more information, including commentary on license choice.
