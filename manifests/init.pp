define deploy (
	$project_name = $title,
	$deploy_files = true,
	$remote_websites_dir = "/data/available-websites",
	$remote_host = "compnet-nexus.bu.edu",
	$remote_user = "deploy",
	$deploy_setup = true,
	$local_websites_dir = "/data/websites",
	$mysql_root_envvars = "/data/puppet/mysql_envvars.sh",
	$project_config_dir = ".config",
) {

	# Class variables
	# ==========================================================================

	$project_path = "${local_websites_dir}/${project_name}"

	# Transfer project code
	# ==========================================================================
	# Note: the `defined()` checks are needed as multiple `deploy` resources
	# may be defined. This prevents same name resource contention in Puppet.

	if ! defined( File[$local_websites_dir] ){
		file { $local_websites_dir:
			ensure => "directory",
			owner => "www-data",
			group => "www-data",
			mode => "0775",
		}
	}

	if ! defined( File["${local_websites_dir}/deploy-files.sh"] ) {
		file { "${local_websites_dir}/deploy-files.sh":
			ensure => "present",
			content => template("deploy/deploy-files.sh"),
			owner => "root",
			group => "root",
			mode => "0700",
			require => [
				File["${local_websites_dir}"],
			],
		}
	}

	exec { "${project_name}-deploy-files.sh":
		command => "${local_websites_dir}/deploy-files.sh ${project_name}",
		onlyif => "test '${deploy_files}' = 'true'",
		path => "/bin:/sbin:/usr/bin:/usr/sbin",
		user => "root",
		group => "root",
		logoutput => "on_failure",
		require => [
			File["${local_websites_dir}/deploy-files.sh"],
		],
	}

	# Setup project
	# ==========================================================================

	if ! defined( File["${local_websites_dir}/deploy-setup.sh"] ) {
		file { "${local_websites_dir}/deploy-setup.sh":
			ensure => "present",
			content => template("deploy/deploy-setup.sh"),
			owner => "root",
			group => "root",
			mode => "0700",
			require => [
				File["${local_websites_dir}"],
			],
		}
	}

	exec { "${project_name}-deploy-setup.sh":
		command => "${local_websites_dir}/deploy-setup.sh ${project_name}",
		onlyif => "test '${deploy_setup}' = 'true'",
		path => "/bin:/sbin:/usr/bin:/usr/sbin",
		user => "root",
		group => "root",
		logoutput => "on_failure",
		require => [
			Exec["${project_name}-deploy-files.sh"],
			File["${local_websites_dir}/deploy-setup.sh"],
		],
	}

}
