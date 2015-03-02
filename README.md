# Cactilize

Ansible role and playbook for deploying and maintaining cacti server and host (graph, devices, templates, tree)

Travis CI [![Build Status](https://travis-ci.org/helldorado/cactilize.png?branch=master)](https://travis-ci.org/helldorado/cactilize)
---------------------

Travis CI is a continuous integration service used by this repo (see [.travis.yml](https://github.com/helldorado/cactilize/blob/master/.travis.yml) for details).

On every new pull request or commit, Travis CI will run a series of checks on the repo.

See [https://travis-ci.org/helldorado/cactilize](https://travis-ci.org/helldorado/cactilize)

Ansible Galaxy [![galaxy](http://img.shields.io/badge/ansible-helldorado.cactilize-brightgreen.svg?style=flat)](https://galaxy.ansible.com/list#/roles/1931)
---------------------

Install this role directly from Ansible Galaxy
```
ansible-galaxy install helldorado.cactilize
```

## Summary

* [Definitions](#definitions)
* [Description](#description)
* [Requirements](#requirements)
* [Host template and Graph Dictionary](#host-template-and-graph-dictionary)
* [Installation](#installation)
* [QuickStart](#QuickStart)
  - [Install and bootstrap an cacti server instance](#install-and-bootstrap-an-cacti-server-instance)
  - [Ready to fire ? GO !](#ready-to-fire?-go-!)
  - [Tips](#tips)
* [Development](#development)
* [Credits](#credits)
* [Licence](#licence)
* [References](#references)

## Definitions

In the following :

 - The **Server** is the host where **cacti server** is installed. Cacti is a complete network graphing solution designed to harness the power of [*RRDTool's*](http://www.rrdtool.org/) data storage and graphing functionality. Cacti provides a fast poller, advanced graph templating, multiple data acquisition methods, and user management features out of the box. All of this is wrapped in an intuitive, easy to use interface that makes sense for LAN-sized installations up to complex networks with hundreds of devices.
 
	 ![cacti](http://www.cacti.net/images/cacti_promo_main.png)
 
 - The **Cacti client** A device, be anything which can be monitored remotely or locally. This can include storage devices, Windows or UNIX servers, and of course network devices. For Cacti to be able to monitor a device, it needs to be reachable by ping or SNMP, but the actual data retrieval can also be done using scripts and commands, or a set of SNMP queries.


## Requirements

 - [Ansible](http://www.ansibleworks.com) installed and ready to work. If not and you have [puppet](http://puppetlabs.com/) master in you architecure, I highly recommend the [nvogel/ansible](http://forge.puppetlabs.com/nvogel/ansible) Module.

 - MySQL 5.x or greater and ensure you have set a auto-login for root by creating a `/root/.my.cnf` on 0400 mode and put this 3 lines according your mysql server configuration. 

 - :coffee: or :beers: 

```yaml
[client]
user=root
host=localhost
password='You mysql server root password'
```

> This role is created for Debian (Squeeze/Wheezy) and compatible with ***ansible >= 1.6***.

## Host template and Graph Dictionary

- [Apache Server HT](https://github.com/helldorado/cactilize/blob/master/vars/def/apache_def.yml)
- [Elasticsearch Host](https://github.com/helldorado/cactilize/blob/master/vars/def/elasticsearch_def.yml)
- [Galera Server HT](https://github.com/helldorado/cactilize/blob/master/vars/def/galera_def.yml)
- [Nginx Server HT](https://github.com/helldorado/cactilize/blob/master/vars/def/nginx_def.yml)
- [Memcached Server HT](https://github.com/helldorado/cactilize/blob/master/vars/def/memcache_def.yml)
- [MongoDB Server HT](https://github.com/helldorado/cactilize/blob/master/vars/def/mongodb_def.yml)
- [MySQL Server HT](https://github.com/helldorado/cactilize/blob/master/vars/def/mysql_def.yml)
- [Redis Server HT](https://github.com/helldorado/cactilize/blob/master/vars/def/redis_def.yml)
- [Varnish Cache](https://github.com/helldorado/cactilize/blob/master/vars/def/varnish_def.yml)
- [ucd/net SNMP Host](https://github.com/helldorado/cactilize/blob/master/vars/def/system_def.yml)

> *For more info about definitions dictionary and howto to modify or add your own definitions dictionnary please refere to the [wiki page](https://github.com/helldorado/cactilize/wiki)*

## Installation

* From Ansible Galaxy :

 ```bash
 su - ansible
 $ ansible-galaxy install helldorado.cactilize
 ```

* From Github with [requirements.yml](https://github.com/helldorado/cactilize/blob/master/examples/requirements.yml) file.

 ```yaml
 - src: https://github.com/helldorado/cactilize
    version: origin/master
     name: cactilize
 ```
 AND
 ```
 ansible-galaxy install -r requirements.yml
 ```
 
* With [Librarian ansible](https://github.com/bcoe/librarian-ansible), for example add to your **Ansiblefile** :

  ```yaml
  role "cactilize", :git => "https://github.com/helldorado/cactilize"
  :ref => '2.0'
  ```
  And update your roles
  ```bash
  $ librarian-ansible update
  ```

Parameters
----------

    VARIABLES                           TYPES/VALUES              DESCRIPTION
    ----------------------------------------------------------------------------------------------------------------------------------------------------------
    deploy                              true|false|force    Deploy an cacti sever or force redeploy. By default  `deploy` => `false`
    webui_admin_user                    STRING              Cacti webui Admin 
    webui_admin_password                STRING              Password for Admin Webui
    htpassword_admin                    STRING              Password for Htpassword for the Admin.
    archi_name                          STRING              Your infrastruture Name. Used for top level Tree.
    archi_subnet                        IPV4                Your infra subnet. Only 3 first bit. Like `10.0.2`. Used for securing the snmp community access.
    default_community                   STRING              Your default community. 
    cacti_db_hostname                   STRING              Cacti database hostname.  
    cacti_db_password                   STRING              Cacti database password
    cacti_mysql_mon_user                STRING              Mysql monitoring User. Used for fectching information from Percona scripts.
    cacti_mysql_mon_pass                STRING              Mysql monitoring password
    RRA_VG_NAME                         STRING              VG NAME, if you want to mount the RRA dir in a LV.
    RRA_LV_NAME                         STRING              LV NAME. By default undef.
    RRA_MOUNT_POINT                     STRING              Where to mount the RRA dir.
    DEFAULT_IP                          IPV4                Default IP autorized to connect on Webui without providing a htpassword password.
    WHITELIST                           IPV4                More IP autorized to connect on Webui without providing a htpassword password. Separate theme by blank space.
    Users                               DICTIONNARY         List of user to be created for access on the Webui. For security raison please provide the htpassword for all user.
    Hosts                               DICTIONNARY         List of Hosts can be graphed. Hosts.graph is a ARRAY. For more info please see Bootsrap section.
    cacti_client_iface                  STRING              Wich interface to use for Hosts or service. By default `cacti_client_iface` => `eth0`
    Tree                                DICTIONNARY         An organised dict to generate your tree. For more info please see Bootsrap section.
    cacti_tree_mode                     STRING              Tree mode to be use. In the version only graph_by_role passe the Run test -;)
    cacti_tree_parentnode_host          STRING              Parent Node for all Hosts. By default `cacti_tree_parentnode_host` => `HOSTS`
    cacti_tree_parentnode_service       STRING              Parent Node for all Service. By default  `cacti_tree_parentnode_service` => `SERVICES`
    apache_server | nginx_server        true|false          Add on all server have apache or nginx. Used for configure the status.conf . Default `undef`
    mysql_server                        true|false          Add on all server have mysql server. Used for configure the user to monitor the mysql sever . Default `undef`
    nfs_client|nfs_server               true|false          Add on nfs client or nfs server.                

## QuickStart

### Install and bootstrap an cacti server instance 

### Examples :
Please edit these files before run the playbook.

- The ansible host file example: [`cactilize-hosts`](https://github.com/helldorado/cactilize/blob/master/examples/cactilize-hosts)

```yaml
## Cacti Server
[server]
spyhc1

## All client to be graph
[client]
spyweb[1:5]
spycache[1:2]
spybdd1

## Look up examples/host_vars and examples/group_vars for more info
[webs]
spyweb[1:5]

[caches]
spycache[1:2]

[databases]
spybdd1
```

- The playbook example file: [cactilize.yml](https://github.com/helldorado/cactilize/blob/master/examples/cactilize.yml).

	  - ```gather_facts``` **MUST BE SET TO** ```yes``` 
	  - **DO NOT SET** ```deploy``` to ```true``` in the playbook. use ```--extra-vars "deploy=true"``` in the command line.

```yaml
# File: cactilize.yml
# Description:
# Playbook for cactilize
#
# OS: Debian6 debian7

---
- hosts: all
  user: ansible
  sudo: True
  gather_facts:  yes
  vars:
    # ABSTRACT
    deploy                : false
    webui_admin_user      : helldorado
    webui_admin_password  : 2A2169234F6BC136j0CFC29EEF8
    htpassword_admin      : DQWWEaTVmoi2I
    archi_name            : SPYNOL
    archi_subnet          : '172.20.20'
    default_community     : spynol
    cacti_db_hostname     : localhost
    cacti_db_password     : tNSimlfnER7d6
    cacti_mysql_mon_user  : monitoring
    cacti_mysql_mon_pass  : 4vtYd5axfavQo
    RRA_VG_NAME           : system
    #RRA_LV_NAME           : var_lib_rra
    RRA_LV_SIZE           : 5G
    RRA_MOUNT_POINT       : '/var/lib/rra'
    DEFAULT_IP            : '127.0.0.1'
    WHITELIST             : ''

    ## Users Access and Permissions
    Users:
      'spyviewer':
         htpassword          : YbXpnONCIG9V2
         password            : FleninOfAt
         full_name           : 'SPY Viewer'
         enabled             : 'on'
         must_change_password:
         permissions         :
           - View_Graphs
           - Export_Data
         policy              :
           - View_Graphs
           - View_Tree
  roles:
   - cactilize
 ```
 
### Manage host_vars and group_vars according your infrastructure

Some examples provided in [Examples](https://github.com/helldorado/cactilize/tree/master/examples) directory :


All hosts can be grouped for setting which services to graph. Ensure if you use an heritage method to leave blank for the item key and do not set the IP. I will get it for you dynamicaly. You can set the `cacti_client_iface` in `group_vars`  or host by host in `host_vars`. Look like:
  
  - [group_vars/webs.yml](://github.com/helldorado/cactilize/blob/master/examples/group_vars/webs.yml)

	```yaml
	---
	cacti_client_iface: eth1
	apache_server: true
	nginx_server: true

	Hosts:
	  '':
	    graph:
	      - system
	      - apache
	      - nginx
	    tree : WEB
	```
  - [group_vars/caches.yml](://github.com/helldorado/cactilize/blob/master/examples/group_vars/caches.yml)
		
	``` 
	---
	cacti_client_iface: eth0:varnish

	Hosts:
	  '':
	    #IP   : 172.20.20.10
	    graph:
	      - system
	      - varnish
	      - memcache
	    tree : CACHE
	```va- [group_vars/databases.yml](://github.com/helldorado/cactilize/blob/master/examples/group_vars/databases.yml)

	```yaml
	---
	cacti_client_iface: eth0:mysql
	mysql_server: true
	```
	
- [host_vars/spybdd1.yml](://github.com/helldorado/cactilize/blob/master/examples/host_vars/spybdd1.yml)

	```yaml
	---
	Hosts:
	  'spybdd1':
	    #IP   : 172.20.20.10
	    graph:
	      - system
	      - mysql
	      - memcache
	    tree : DATABASES

	  'spybdd1_redis':
	    IP   : 172.20.20.70
	    graph:
	      - redis
	    tree : NoSQL
	```

- [host_vars/spyhc1.yml](://github.com/helldorado/cactilize/blob/master/examples/host_vars/spyhc1.yml) ::bangbang:: Tree Dict need to be set only in Cacti server host_vars. Remove/Add/Organize them according your tree plan.

	```yaml
	---

	Hosts:
	  'spyhc1':
	    IP   : 172.20.20.20
	    graph:
	      - system
	    tree : SYS

	## TREE
	Tree:

	  - node: "{{ cacti_tree_parentnode_service }}"
	    subnodes:
	      -

	  - node: "{{ cacti_tree_parentnode_host }}"
	    subnodes:
	      -

	  - node: WEB
	    subnodes:
	      - NGINX
	      - APACHE
	      - LIGHTTPD

	  - node: CACHE
	    subnodes:
	      - VARNISH
	      - OPCODE

	  - node: DATABASES
	    subnodes:
	      - MYSQL
	      - GALERA

	  - node: NoSQL
	    subnodes:
	      - REDIS
	      - MEMCACHE
	      - MONGODB
	      - ES

	  - node: SYSTEM
	    subnodes:
	      - NETWORK
	      - CPU
	      - MEMORY
	      - DISK
	```

> You can create several devices, tree and users.


### Install, configure and graph... 

 
```bash
ansible-playbook cactilize.yml -i cactilize-hosts --extra-vars "deploy=true"
```

* :warning: Do not use `--extra-vars "deploy=true"` again unless you want to override you installation. Anyway, for that you must set `--extra-vars "deploy=force"`

> This will take some time according your devices and graph list, be patient...

* You can check if all your clients SNMP configuration is good with this command. Replace `YOUR_COMMUNITY` with community your are provided in playbook

	```bash```
	ansible all  --sudo  -m shell -a "snmpwalk -v2c -c YOUR_COMMUNITY localhost IP-MIB::ipAdEntIfIndex"
	```

> **check the report file `/root/.cacti` in you cacti server for recap information.**

## Tips
- Allways use and ABUSE **--tags** and **--skip-tags**

	```
	SERVICE => mysql | mongodb | redis | galera | varnish | memcache | apache | nginx | elasticsearch
	```


	| List of Tags | Description |         Examples |            
	| -------------| ------------- |----------------|
	|  master_user | Create cacti user on server  |```ansible-playbook cactilize.yml -i cactilize --limit server --tags master_user ```|
	|  report      | Create report file  |```ansible-playbook cactilize.yml -i cactilize --limit server --tags report``` |
	|  device      | Create all device  | ```ansible-playbook cactilize.yml -i cactilize --limit server --tags device```|
	|  graph       | Create all graph | ```ansible-playbook cactilize.yml -i cactilize --limit server --tags graph``` |
	|  graph-$SERVICE| Create $SERVICE graph only| ```ansible-playbook cactilize.yml -i cactilize --limit server --tags graph-nginx```|
	|  snmp|Configure snmpd service|```ansible-playbook cactilize.yml -i cactilize --limit server --tags snmp```|
	|  user |Create cacti user on client| ```ansible-playbook cactilize.yml -i cactilize --limit client --tags user```|
	|  nginx_server| Enable Nginx Status| ```ansible-playbook cactilize.yml -i cactilize --limit client --tags nginx_server```|
	|  apache_server|Enable Apache Status| ```ansible-playbook cactilize.yml -i cactilize --limit client --tags apache_server```|
	|  mysql_server|Grants monitor user| ```ansible-playbook cactilize.yml -i cactilize --limit client --tags mysql_server```|
	|  ssh_key | Deploy the ssh key| ```ansible-playbook cactilize.yml -i cactilize --limit client --tags ssh_key```|
	|template |Import host template|```ansible-playbook cactilize.yml -i cactilize --limit server --tags template```|
	|tree|Create all tree|```ansible-playbook cactilize.yml -i cactilize --limit server --tags tree --skip-tags tree-apache```|
	|tree-$SERVICE|Create $SERVICE tree only|```ansible-playbook cactilize.yml -i cactilize --limit server --tags tree-varnish```|

- If possible or necessary use **--start-at-task** to start from a specific task 

	```bash
	ansible-playbook cactilize.yml -i cactilize --limit client --start-at-task "SNMP CONF"
	``` 
For example to show task related device or graph, type: 
```bash 
$ ansible-playbook cactilize.yml -i cactilize  --list-tasks |grep -Ei 'device|graph'
    ADD device
    ADD Graph SYSTEM
    ADD Graph MYSQL
    ADD Graph MONGODB
    ADD Graph REDIS
    ADD Graph GALERA
    ADD Graph VARNISH
    ADD Graph MEMCACHED
    ADD Graph APACHE
    ADD Graph NGINX
    ADD Graph Elasticsearch
    ADD NODES TREE WHEN TREE MODE LIKE GRAPH BY ROLE
    ADD SUB NODES WHEN TREE MODE LIKE GRAPH BY ROLE
    ADD HOST ON TREE HOST WHEN TREE MODE LIKE GRAPH BY ROLE
    ADD GRAPH MYSQL ON TREE OR NODE
    ADD GRAPH APACHE ON TREE OR NODE
    ADD GRAPH NGINX ON TREE OR NODE
    ADD GRAPH MEMCACHE ON TREE OR NODE
    ADD GRAPH REDIS ON TREE OR NODE
    ADD GRAPH VARNISH ON TREE OR NODE
    ADD GRAPH ELASTICSEARCH ON TREE OR NODE 
  ```
    
## Development

### Bugs and feature requests

Have a bug or a feature request? Please first check the list of issues.

If your problem or idea is not addressed yet, please open a new issue, or contact me at [devops@helldorado.info](devops@helldorado.info)

### Contributing

You're welcome to propose pull requests. Here's a quick guide.

Fork, then clone the repo:

    git clone git@github.com:your-username/cactilize

Set up your ansible environement for test suite.

Make sure the tests pass via the **Vagrantfile** and **Rspec** :

Make your change. Add examples and documentation for your change. 
Push to your fork and [submit a pull request](https://github.com/helldorado/cactilize/compare/).



```bash
.
├── Vagrantfile
├── cactilize -> ../../cactilize
├── data
│   └── cactilize
├── group_vars
│   ├── caches.yml
│   ├── databases.yml
│   └── webs.yml
├── host_vars
│   ├── client5.yml
│   └── server.yml
├── inventory
├── my.cnf
└── playbook.yml
```

File `tests/Vagrantfile`
```
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/debian-73-x64-virtualbox-nocm.box"
  
  config.vm.define :client1 do |client1|
    config.vm.hostname = "cacti-client1"
    client1.vm.network "private_network", ip: "172.20.20.10"
  end

  config.vm.define :client2 do |client2|
    config.vm.hostname = "cacti-client2"
    client2.vm.network "private_network", ip: "172.20.20.11"
  end

  config.vm.define :client3 do |client3|
    config.vm.hostname = "cacti-client3"
    client3.vm.network "private_network", ip: "172.20.20.12"
  end

  config.vm.define :client4 do |client4|
    config.vm.hostname = "cacti-client4"
    client4.vm.network "private_network", ip: "172.20.20.13"
  end

  config.vm.define :client5 do |client5|
    config.vm.hostname = "cacti-client5"
    client5.vm.network "private_network", ip: "172.20.20.14"
  end

  config.vm.define :server do |server|
    config.vm.hostname = "cacti-server"
    server.vm.network "private_network", ip: "172.20.20.20"
    server.vm.network "forwarded_port", guest: 80, host: 8080
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.sudo = true
    ansible.host_key_checking = false
    ansible.groups = {
          "server" => "server",
          "client" => "client",
    }
  end
end
```
#### - To bring the test system up, do the following:
		
```bash
cd roles/cactilize/tests
```

* UP your Vagrant machines *(This stage can last for the first launch. Be patient.)* You can remove client machines [2-5]
	  
```bash
 vagrant up
```

* Add the SSH connection information to your SSH config, from where Ansible can read it:

```bash
vagrant ssh-config >> ~/.ssh/config
```

Now you are ready to run the Ansible roles:
```bash
ansible-playbook -i inventory playbook.yml --extra-vars "deploy=true"
```
	

- Run the **Rspec** tests suite via **ServerSpec**. For more info check [http://serverspec.org/ ](http://serverspec.org/)

* Install ServerSpec via gem

```bash
gem install serverspec
```

For first run, init your ServerSpec
```bash
serverspec-init
```

And run Rspec test suite.
```bash
rake spec:server
```

Rspec Sample Output

![Cactilize Rspec Sample Output](https://github.com/helldorado/cactilize/blob/master/examples/img/cactilize_rspec.png)


You can find the documatation on using **Vagrant** and **ServerSpec** via the following links.`

- [Vagrant](https://docs.vagrantup.com/v2/provisioning/ansible.html)
- [ServerSpec](http://serverspec.org/resource_types.html)



Some things that will increase the chance that your pull request is accepted:

* Write tests, see Travis CI section or/and ansible [Testing Strategies](http://docs.ansible.com/test_strategies.html)
* Follow ansible playbook best pratices [style guide]().
* Write a [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).


## Credits

* **Abdoul Bah**
* [All contributors](https://github.com/helldorado/cactilize/graphs/contributors)

## Licence

Cactilize ansible role is released under the GPL2 License. Check the [LICENSE](https://github.com/helldorado/cactilize/blob/master/LICENSE) file for details.

## References

- [Ansible](http://www.ansibleworks.com)
- [Ansible Playbook](http://docs.ansible.com/playbooks.html)
- [Ansible Role](http://docs.ansible.com/playbooks_roles.html)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [YAML Gotchas](http://www.yaml.org/spec/1.2/spec.html)
- [Cacti® - The Complete RRDTool-based Graphing Solution](http://www.cacti.net/)
- [Percona Monitoring Plugins](http://www.percona.com/doc/percona-monitoring-plugins/1.1/)
- [Contributing to open-source](https://guides.github.com/activities/contributing-to-open-source)
- [About commit](https://help.github.com/categories/commits/)
