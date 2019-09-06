# Module remediate_install

## Table of Contents

1. [Description](#description)
2. [System requiements](#system-equirements)
3. [License](#öicense)
4. [Before you start](#before-you-start)
5. [Usage - Configuration options and additional functionality](#usage)
6. [Reference](#reference)
7. [Limitations](#limitations)
8. [Development - Guide for contributing to the module](#development)
9. [Changelog](#changelog)
10. [Contributors](#contributors)

## Description

The module provides tasks and plans arround the installation of Puppet Remediate. Remediate is shipped as a bunch of docker containers. 

## System requirements

Remediate has its own system requirements. Before you begin to install, please check the [system requirements](https://puppet.com/docs/remediate/latest/system_requirements.html) here. This module can check the system requirements and stop the installation if the requirements are not met.

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

This step will install all needed Puppet modules into the remediate_install modules folder.

## Usage

This module contains two Bolt plans. One plan is for checking the system requirements only. The second one is for installing Remediate on your system.

### Checking system requirements

```puppet
bolt plan run remediate_install::check_requirements -n localhost
```

### Installing remediate

```puppet
bolt plan run remediate_install install_docker=y init_swarm=y \
    license_file=/opt/remediate/license.json remove_old=y install_compose=y \
    install_remediate=y configure_firewall=y -n localhost --run-as root
```

## Reference

See [REFERENCE.md](https://github.com/tom-krieger/sremediate_install/blob/master/REFERENCE.md)

## Limitations

This first version is only tested with CentOS. More operation systems to follow.

## Development

Contributions are welcome in any form, pull requests, and issues should be filed via GitHub.

## Changelog

See [CHANGELOG.md](https://github.com/tom-krieger/remediate_install/blob/master/CHANGELOG.md)

## Contributors

