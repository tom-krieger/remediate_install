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

The installation process needs several files from the internet. Puppet modules will be downloaded, Docker will be installed and docker-compose as well. Please make sure internet access is possible.

## System requirements

Remediate has its own system requirements. Before you begin to install, please check the [system requirements](https://puppet.com/docs/remediate/latest/system_requirements.html). This module can check the system requirements and stop the installation if the requirements are not met. Additionally there's a plan for checking only the requirements and printing log messaged if some requirements are not met.

## License

Remediate needs a license flle to run. You can apply for a test license at [licenses.puppet.com](https://licenses.puppet.com). To get a license please follow these instructions:

- Click 'Get License'
- Click '30-day Free Trial'
- Download your license (json file)
- Save your license to the directory where you plan to install Remediate

## Before you start

Clone this module from [Github](https://github.com/tom-krieger/remediate_install.git) and follow the instructions below. 

```puppet
cd remediate_install

bolt puppetfile install
```

This step will install all needed Puppet modules into the remediate_install modules folder. You can see which modules will be installed by having a look into the Puppetfile in the module.

## Usage

This module contains two Bolt plans. One plan is for simply checking the system requirements. The second plan is for installing Remediate on your system.

### Checking system requirements

```puppet
bolt plan run remediate_install::check_requirements -n localhost
```

### Installing remediate

```puppet
bolt plan run remediate_install install_docker=y init_swarm=y \
    license_file=/opt/remediate/my-remediate-license.json install_compose=y \
    install_remediate=y configure_firewall=y -n localhost --run-as root
```

The installer will copy the license file into the Remediate installation directoy and will download the requierd docker compose file to fire up Remediate.

## Reference

See [REFERENCE.md](https://github.com/tom-krieger/sremediate_install/blob/master/REFERENCE.md)

## Limitations

This first version is only tested with CentOS. More operation systems to follow.

Currently there is no possibilty to use a proxy for internet access.

## Development

Contributions are welcome in any form, pull requests and issues should be filed via GitHub.

## Changelog

See [CHANGELOG.md](https://github.com/tom-krieger/remediate_install/blob/master/CHANGELOG.md)

## TODOs

- Add options to configure prox access to the internet for downloading Docker, docker.compose, Remediaste compose file and so on

## Contributors
