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

# Server Filesystem #

Available projects are stored on the puppet server in the following configuration:

	available-websites/my-project
	available-websites/my-project/files/ # Git repository or flat files
	available-websites/my-project/backup/
	available-websites/my-project/backup/latest/
	available-websites/my-project/backup/automated-backup-2013-01-01.tar.gz
	available-websites/my-project/backup/automated-backup-2012-01-01.tar.gz

Inside the `my-project/files` directory should be a current group of files
and/or a git repository of files.

This module uses the default backup directory structure of the puppet-backup
module. The puppet-backup module will create the `backup/`, put the latest
files in `backup/latest`, and create archives based on a round-robin backup
scheme and Puppet parameters passed to the class.

Future revisions of this module will allow custom backup directory
structures through passable puppet parameters.

# Project Filesystem #

The project files should include a `.config` directory. This contains meta
information about the project, including information on how to deploy. It may
contains directories such as:

	.config/
	.config/mysql-appusers/
	.config/mysql-appdata/
	.config/scripts/

Where a `mysql-*` directory includes the filels:

	.config/mysql-appusers/database.sql
	.config/mysql-appusers/name
	.config/mysql-appusers/schema.sql
	.config/mysql-appusers/users.sql

**Note:** If there is only one database, then the dir can simply be called
`mysql`.

The `scripts/` directory stores pre-deploy, post-deFuture revisions of this module will allow custom backup directory
structures through passable puppet parameters.ploy, and post-deploy smoke
test scripts.

License
================================================================================

All code written by me is released under MIT license. See the attached
license.txt file for more information, including commentary on license choice.
