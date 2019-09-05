# Module remediate_install

## Table of Contents

1. [Description](#description)
2. [System requiements](#system-equirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

The module provides tasks and plans arround the installation of Puppet Remediate. Remediate is shipped as a bunch of docker containers

## System requirements

Remediate has its own system requirements. Before you begin to inxtall, please check the [system requirements](https://puppet.com/docs/remediate/latest/system_requirements.html) here. This module can check the systemrequirements and stop installation if the requirements are not met.

## License

Remediate needs a licensw fle to run. You can apply for a test license at [licenses.puppet.com](https://licenses.puppet.com). To get a license please follow these instructions:

- Click 'Get License'
- Click '30-day Free Trial'
- Download your license (json file)
- Save your license to the directory where you plan to install Remediate

## Usage

Include usage examples for common use cases in the **Usage** section. Show your users how to use your module to solve problems, and be sure to include code examples. Include three to five examples of the most important or common tasks a user can accomplish with your module. Show users how to accomplish more complex tasks that involve different types, classes, and functions working in tandem.

```puppet
cd remediate_install
bolt puppetfile install
bolt plan run remediate_install install_docker=y init_swarm=y license_file=/opt/remediate/vr-license.json \
    remove_old=y install_compose=y install_remediate=y configure_firewall=y -n localhost --run-as root
```

## Reference

This section is deprecated. Instead, add reference information to your code as Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your module. For details on how to add code comments and generate documentation with Strings, see the Puppet Strings [documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) and [style guide](https://puppet.com/docs/puppet/latest/puppet_strings_style.html)

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the root of your module directory and list out each of your module's classes, defined types, facts, functions, Puppet tasks, task plans, and resource types and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

This first version is only testes with CentOS. More operation systems to follow.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
