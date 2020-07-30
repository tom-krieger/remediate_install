# Module remediate_install

## Table of Contents

1. [Description](#description)
2. [System requiements](#system-equirements)
3. [License](#öicense)
4. [Before you start](#before-you-start)
5. [Usage](#usage)
6. [Reference](#reference)
7. [Limitations](#limitations)
8. [Development](#development)
9. [Changelog](#changelog)
10. [Contributors](#contributors)

## Description

The module provides Bolt plans arround the installation of Puppet Remediate. Remediate is shipped as a bunch of docker containers. 

The installation process needs several files from the internet. Puppet modules will be downloaded, Docker will be installed and docker-compose as well. Please make sure internet access is possible on your computer running the Bolt plan and on the server installing Remediate.

## System requirements

Remediate has its own system requirements. Before you begin to install, please check the [system requirements](https://puppet.com/docs/remediate/latest/system_requirements.html). This module can check the system requirements and stop the installation if the requirements are not met. Additionally there's a plan for checking only the requirements and printing log messages if some requirements are not met.

Bolt uses winrm transport to connect to the Windows boxes. Please make sure the Windows boxes have winrm enabled and firewalls are configured to grant access to the winrm ports on the Windows boxes.

## License

Remediate needs a license flle to run. You can apply for a test license at [licenses.puppet.com](https://licenses.puppet.com). To get a license please follow these instructions:

- Click 'Get License'
- Click '30-day Free Trial'
- Download your license (json file)
- Save your license to the directory where the installer can access it

## Before you start

Clone this module from [Github](https://github.com/tom-krieger/remediate_install.git) and follow the instructions below. 

```puppet
cd remediate_install

# install all Puppet modules needed
bolt puppetfile install

# upload your Remediate license to remote Linux box
bolt file upload /tmp/license.json /tmp/license.json -n <host> --user <user> \
          [--private_key <private key file>] [--password] --no-host-key-check

# upload your Remediate license to a remote Windows box
bolt file upload /tmp/license.json c:\license.json -n <host> \
          --user Administrator --password <password> --transport winrm --no-ssl
```

## Usage

This module contains two Bolt plans. One plan is for simply checking the system requirements. The second plan is for installing Remediate on your system.

If you have a managed firewall running on the box installing Remediate please make sure to aet the parameter for the firewall configuration during installation to 'n'. Otherwise you may have issues with the fireweall rules mixed up.

### Checking system requirements

#### Linux

```puppet
bolt plan run remediate_install::check_requirements -n <host> --run-as root --user <user> \
          [--private_key <path to privare-key>] [--password] --no-host-key-check
```

#### Windows

```puppet
bolt plan run remediate_install::check_requirements -n <host> --user Administrator \
           --password <password> --transport winrm --no-ssl
```

### Installing Remediate

#### Linux

```puppet
bolt plan run remediate_install install_docker=y init_swarm=y license_file=/tmp/license.json \
          install_compose=y install_remediate=y configure_firewall=y -n <host> --run-as root \
          --user <user> [--private_key <path to privare-key>] [--password] --no-host-key-check \
          [--sudo-password [PASSWORD]]
```

#### Windows

```puppet
bolt plan run remediate_install install_docker=y docker_ee=true init_swarm=y \
          license_file=c:\license.json compose_install_path="C:/Program Files/Docker" \
          install_compose=y install_remediate=y configure_firewall=y -n <host> --no-ssl \
          --user Administrator --password <password> --transport winrm
```

The installer will copy the license file into the Remediate installation directoy and will download the required docker compose file to fire up Remediate.

## Reference

### Classes

#### Public Classes

#### Private Classes

- `remediate_install::firewall`: Configure firewall if needed
- `remediate_install::firewall::linux`: Firewall definition for Linux
- `remediate_install::firewall::linux::post`: Firewall post rules
- `remediate_install::firewall::linux::pre`: Firewall pre rules
- `remediate_install::firewall::windows`: Firewall definition for windows
- `remediate_install::install`: Install Puppet remedeiate docker containers
- `remediate_install::install::linux`: Install remediate oin Linux
- `remediate_install::install::linux::service`: Install a service for remediate
- `remediate_install::install::windows`: Install remediate on windows
- `remediate_install::install::docker`: Install docker and its prerequisites

### Tasks

- [`uninstall_remediate`](#uninstall_remediate): Uninstall Remediate

#### Plans

- [`remediate_install`](#remediate_install): Install Puppet Remediate
- [`remediate_install::check_requirements`](#check_requirements): Check Remediate installation prerequisites

### Parameters

#### remediate_install

The following parameters are available in the `remediate_install` plan.

##### `nodes`

The target nodes

##### `install_docker`

Flag for Docker install.  
Valid input: 'y' or 'n'

##### `init_swarm`

Initialize Docker Swarm during installation. This will initialize a first swarm manager node.  
Valid input: 'y' or 'n'

##### `install_compose`

Install docker-compose binary which is needed for Remediate installation.  
Valid input: 'y' or 'n'.

##### `compose_version`

The version of docker-compose to install if installation of docker-compose is requested. Please keep in mind that Remedieate needs version 1.24.1 of docker-compose at least.

##### `install_remediate`

Install Remediate.  
Valid input: 'y' or 'n'

##### `configure_firewall`

Setup a firewall with all rules needed for Remediate. If unsure please set this parameter to no and do the firewall configuration yourself. If you manage the firewall on the box with Puppet or some other tool please set this parameter to 'n'.  
Valid input: 'y' or 'n'

##### `license_file`

Full qualified filename of the Remediate license file on your local system. Upload will be done by installer.

##### `docker_users`

Users to add to the docker group

##### `compose_install_path`

Path where to install docker-compose binary.

##### `win_install_dir`

Directory where to install Remediate on Windows boxes

##### `unix_install_dir`

Directory where to install Remediate on Unix systems

##### `enforce_system_requirements`

Set to true the installer breaks if the system requirements for Remediate are not met.

##### `noop_mode`

Run apply commands in noop mode. If set to true no changes will be made to the system

##### `docker_ee`

Flag to install Docker Enterprise. Must be set to true on Windows boxes.

#### `check_requirements`

The following parameters are available in the `remediate_install::check_requirements` plan.

##### `nodes`

Data type: `TargetSpec`

Nodes to run on

#### uninstall_remediate

The following parameters are available in the `remediate_install::uninstall_remediate` task.

##### `install_dir`

Data type: `String[1]`

Installation directory

**Supports noop?** false

## Limitations

This module supports:

- Centos 7
- RedHat 7
- RedHat 8
- Debian 8
- Debian 9
- Ubuntu 14.04
- Ubuntu 16.04
- Ubuntu 18.04
- Windows Server 2016 (Docker Enterprise Edition only)
- Windows 10 (Docker Enterprise Edition only)

This first version is only tested with CentOS 7 and Ubuntu 18.04. More operation systems to follow.

Currently there is no possibilty to use a proxy for internet access.

## Development

Contributions are welcome in any form, pull requests and issues should be filed via GitHub.

## Changelog

See [CHANGELOG.md](https://github.com/tom-krieger/remediate_install/blob/master/CHANGELOG.md)

## TODOs

- Add options to configure proxy access to the internet for downloading Docker, docker-compose, Remediaste compose file and so on

## Contributors
