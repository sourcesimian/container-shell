Container Shell Pattern<!-- omit in toc -->
===

***A template project for building your own containerised toolset***

Too often I've seen a team member detoured because some tooling they need is not yet installed, is too tricky or time consuming to setup right now, is the wrong version, or has broken. To me this is an insanity of inefficiency, since at that same point in time that tooling is sure to already be installed and available on another team member's machine. Further is is not uncommon to see tooling behaving differently on different machines, which can result in diversions from the task at hand. These detours are needless wasted time. The *Container Shell Pattern* is a team tooling technique to overcome these inefficiencies, improve tooling consistency and facilitate immediate team wide access to tooling.

This [project is a working example](https://github.com/sourcesimian/container-shell) as a starting point to building your own container shell.

- [Pattern](#pattern)
  - [Goals](#goals)
  - [Highlevel](#highlevel)
  - [Installation](#installation)
  - [User Experience](#user-experience)
    - [File System](#file-system)
    - [Canonical Command Lines](#canonical-command-lines)
    - [Executable Search Path](#executable-search-path)
- [Make your Own Container Shell](#make-your-own-container-shell)
  - [Building](#building)
  - [Installation](#installation-1)
    - [Moving Docker images](#moving-docker-images)
  - [Usage](#usage)
  - [Customising](#customising)
  - [Evangelising](#evangelising)
- [Idioms](#idioms)
  - [Container Shell Options](#container-shell-options)
    - [Different User Names](#different-user-names)
    - [Exposing Ports](#exposing-ports)
    - [Attaching to an Existing Shell](#attaching-to-an-existing-shell)
    - [Choosing the Shell Interpreter](#choosing-the-shell-interpreter)
  - [Root Permissions](#root-permissions)
    - [Full User Setup](#full-user-setup)
    - [Docker Socket Access](#docker-socket-access)
    - [Sudo](#sudo)
  - [User Environment Variables](#user-environment-variables)
    - [Multiple Tool Versions](#multiple-tool-versions)
    - [Team Source Root Directory](#team-source-root-directory)

# Pattern
Tooling can be separated into two primary groups *system* and *user*. The *user* grouping can be broadly classified as anything that is different for each user, this includes identity, authorisation, environment customisations, utility scripts, and in progress source. The *system* grouping is all the binaries, packages, modules and tool chains that get installed. The *Container Shell Pattern* aims to simplify access to the *system* group by achieving the following goals.

## Goals
The *Container Shell Pattern* is a way of achieving the following goals:
* make all common team tooling rapidly available with low effort setup,
* minimal affectation to user machine,
* consistent environment in which tooling is run,
* canonical command line usage,
* easily switch between toolset versions.

By meeting these goals it should mean that a new starter is able to be contributing in hours, if not minutes. Additional tooling should be available to all team members with no further effort as soon as the first team member starts using it. The cost of failed equipment or moving to other machines should be trivial. Tooling behaviour and output is consistent across operating systems and distributions. And depending on the team's CI/CD philosophy, the same container shell could provide consistency across different stages of the production line too. Team members can easily select the version of toolset which is applicable to their current focus. Discussions, assistance and documentation about tooling usage follow the same canonical command line usage, in other words what works for one can work for all.

## Highlevel
Essentially the *Container Shell Pattern* is a container launched with the local user's permissions, some of the environment and the user's home directory mounted in. It can be dropped into like a conventional shell, or used as a prefix command. When in the shell, normal user permissions and home file system access is maintained, while the executables, tool chains and packages come from the container.

It is up to your team what gets installed in your container shell, it could be anything you regularly use. Any tooling or tool chain which is used in the team which others would benefit from if it was immediately available and ready to use is a candidate. Particularly good examples are things like your collection of diagnostic tools, the specific runtime environment you use, code analysis, compilers, API libraries, CLI bindings, infrastructure as code tools, etc. It is up to you. Further, you may also carefully consider using more than one container shell, for different areas of your operations.

## Installation
A goal of the *Container Shell Pattern* is to minimise installation effort. To achieve this we ensure that the only needed artefact is a container, and the default entrypoint will output the installation instructions. This makes the solution self documenting and one only needs to run `docker run <image>` to get the installation instructions. Installation will write a minimal launcher script to the user's path effectively abstracting the docker invocation.

## User Experience
### File System
The container shell is intended to behave as naturally as a normal user shell, in that the current, relative and absolute filesystem locations and file system permissions are consistent with a normal user session. While the operating system and binaries are from within the container. One should be able to interactively drop into the shell, and use the shell as command prefix which provides the executable context to the invoked command, e.g.
```
user@mac$ cosh
user@cosh-mac$ my-tool-invocation ...
```
or
```
user@mac$ cosh my-tool-invocation ...
```
### Canonical Command Lines
In a team it is quite often that one person wishes to know how someone else did a thing. The answer may come in the form of a Slack message or Wiki page document. And often it may not be clear to that person from where this tool is available, or the user will need to make some adjustments to the command line. This is where the concept of *canonical command lines* is powerful. Any tooling in the container shell can be directly referenced by prefixing the command with the launcher stub, e.g.:
```
$ cosh run-autogeneration --servers all
```
Thus the command line can simply be copy pasted and will work for any team member. Additionally this command line should work the same way whether pasted into a shell or an existing container shell.

### Executable Search Path
The user should have access to the `PATH` and utility scripts within their home directory, so that they may still take advantage of any ad-hoc or utility scripts they may write or use.

# Make your Own Container Shell
To develop your own container shell you can follow the following steps:

## Building
Checkout the source of this [container-shell repository](https://github.com/sourcesimian/container-shell) which can be used as a starting point to creating your own container shell.

Run `make cosh` to build the container. Later when you intend building your own container shell copy this repository to your own.

## Installation
Just run `docker run --rm <image>`, and follow the instructions.

### Moving Docker images
If your team does not have a docker registry it is still easy to copy an image around, e.g.:
```
user1@host1$ docker save cosh:1 | gzip > cosh~1.tar.gz
...
user2@host2$ docker load -i cosh~1.tar.gz
```
Or as a single `ssh` stanza: 
```
user1@host1$ docker save cosh:1 | gzip | ssh user@host docker load
```

## Usage
Take a look at the container help by running `cosh --help`. Try dropping into the container shell by running `cosh`. Look about at the filesystem structure, run `pwd`, try `touch`ing a file. Run `ls -l`, `ls /` and `ls /tmp`, both outside and inside the shell. Observe your permissions. Observe the difference in output of `uname -a` on your machine and in the container shell. See that `shellcheck` is available from inside the container shell, but may not be or is another version on your machine.

## Customising
Now once you have taken a copy of the template, you can start adding your commonly used packages, tools etc to [Dockerfile](https://github.com/sourcesimian/container-shell/blob/main/Dockerfile). You can take a look at how [stub.sh](https://github.com/sourcesimian/container-shell/blob/main/docker/cosh/stub.sh), [launcher.sh](https://github.com/sourcesimian/container-shell/blob/main/docker/cosh/launcher.sh) and [entrypoint.sh](https://github.com/sourcesimian/container-shell/blob/main/docker/cosh/entrypoint.sh) are used to invoke a container shell. And you can update the help, rename environment variable prefixes and the launcher to suit your team.

## Evangelising
If you intend using the container shell pattern in your team I suggest you evangelise the goals, give demonstrations of how it would work and point your team mates to this document. A container shell will work best if your team has a good understanding of how it will benefit them, that it is used by all regularly, and that the source is living and contributed to by all.

# Idioms
Building a container shell is about building a productivity accelerator specific to your team. Your container shell will most likely become highly customised to the needs of your team. There are however some common idioms which you might still find advantageous.

## Container Shell Options
The template container shell accepts several environment variables which can be used to parameterise the invocation:

### Different User Names
Some tooling requires the use of a specific username that is not the same as that on your machine. I've  seen team members repeatedly logging in and out as different users, or even reinstalling their machines to achieve this. This template container shell can be invoked to use a different username by setting the  `COSH_USER` environment variable, e.g.:
```
source@mac$ whoami
source
source@mac$ export COSH_USER=ssimian
source@mac$ cosh whoami
ssimian
```
Typically `COSH_USER` could be set in the user's environment and then mostly forgotten.

### Exposing Ports
Running tools in a container can be constrictive in exposing ports to your local machine. This template container shell can expose selected ports by setting  `COSH_PORTS` e.g.:
```
COSH_PORTS=8080,8443 cosh ...
```

### Attaching to an Existing Shell
By default each container shell runs as a separate container, however should you wish to reenter a specific container this template provides a helper. From inside the shell `cosh id` will provide the container Id. And then setting the `COSH_ID` will instruct the launcher script to `exec` into that container rather than `run`'ing a new one.

### Choosing the Shell Interpreter
By default this template will run as `bash` however it is possible to set the default shell interpreter as `zsh` by setting the `COSH_SHELL` environment variable. 

To improve shell support follow `COSH_SHELL` through from [entrypoint.sh](https://github.com/sourcesimian/container-shell/blob/main/docker/cosh/entrypoint.sh). Notice how `cosh.env.sh` is sourced from `entrypoint.sh` and `zshrc` is written to  `/etc/zsh/zshrc.cosh`


## Root Permissions
A container shell is built as a generic non-user specific container, specifically because it is intended as a team wide solution that is easy to install and use. When the container is launched, code in [entrypoint.sh](https://github.com/sourcesimian/container-shell/blob/main/docker/cosh/entrypoint.sh) will perform  some user specific customisations. But a container shell is specifically run with the user's permissions, to provide the seamless user experience and also because running containers as root is genrally a bad idea. Thus the user permissions are insufficient for some of the necessary setup operations.

To resolve tis several setup executables are compiled at Docker build time, set as owned by root and the `setuid` flag set, so that when run they can elevate permissions and make the necessary changes.

### Full User Setup
[setupuser.c](https://github.com/sourcesimian/container-shell/blob/main/docker/setupuser.c) is used to provide a full user setup for tools such as `id` and `ssh`, e.g.:
```
user@mac$ COSH_USER=monkey cosh
monkey@cosh-mac$ id -u -n
monkey
```

### Docker Socket Access
[setupdocker.c](https://github.com/sourcesimian/container-shell/blob/main/docker/setupdocker.c) is used to setup the docker socket provide a working docker CLI in the container shell.

### Sudo
Since a container shell is intended as development utility and typically it is a bad idea to to make use of `sudo` in build or development scripts, this template contains a `sudo` stub which acts as a pass through outputting a message to the console, but does not elevate permissions. Alternatively it could be coded to just error out to help catch these usages.

## User Environment Variables
As mentioned above, a container shell takes *some* of the user's environment. What gets used is up to how you choose to customise your container shell. But typically you want to be restrictive, only choosing that which you specifically want, so that your container shell provides a more consistent environment.

The environment variables are selected in [launcher.sh](https://github.com/sourcesimian/container-shell/blob/main/docker/cosh/launcher.sh). For example see how `cosh_env()` is used. This selection is up to how you choose to customise your container shell.

### Multiple Tool Versions
There may be times where your team is migrating from one version of a tool to another. For example to support both Helm v2 and v3 you could add `^HELM_`, or even just `^HELM_VERSION=`, to `cosh_env()`.

In the `Dockerfile` install the binaries as `helm2` and `helm3`. And add a `/usr/bin/helm` stub like:
```
#!/bin/bash
HELM_VERSION=${HELM_VERSION:-2}  # default to v2
exec /usr/bin/helm${HELM_VERSION} "${@}"
```
Initially, default to the existing version to maintain behaviour, later default to the latest version, finally remove the v2 binary.

### Team Source Root Directory
I take no issue where people choose to locate their project folders on their machines. I do however suggest that all software teams establish an environment variable that points to the root of their collection of source trees in the shape of:
```
export MYTEAM_ROOT=~/work/MYTEAM
```
This single standard environment variable can then be used as an anchor from which many other tooling can run in a consistent manner. This would mean making an addition to `cosh_env()`:
```
            env | grep -e ... -e '^MYTEAM_'
```
The expectation would be that all team members set the value of `MYTEAM_ROOT` in their environment.
