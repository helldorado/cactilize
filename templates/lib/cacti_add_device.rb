#!/usr/bin/env ruby

# 2014 ::  Abdoul Bah <devops@helldorado.info>
# Add Device Ruby wrapper for the cacti cli API.
#
# This program is free software. It may be redistributed and/or modified under
# the terms of the GPL version 2 (or later) or the Ruby licence.

class Cacti_add_device
  require 'optparse'

  def param

    $options = {}

    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: cacti.add_device.rb PARAMETERS [VALUES]"
      opt.separator  ""
      opt.separator  "Parameters:"

      opt.on("--description DESC", "description (required)     - the name that will be displayed by Cacti in the graphs.") do |description|
          $options[:description] = description
      end

      opt.on("--ip IP_HOST","IP (required)              - self explanatory (can also be a FQDN).") do |ip|
        $options[:ip] = ip
      end

      $options[:template] = "ucd/net SNMP Host"
      opt.on("--template TEMPLATE", "template (optional)        - id of template to use, if any.") do |template|
          $options[:template] = template
      end

      $options[:notes] = ""
      opt.on("--notes NOTES","notes (optional)           - General information about this host.") do |notes|
        $options[:notes] = notes
      end

      $options[:avail] = "snmpuptime"
      opt.on("--avail AVAILABILITY", "avail (optional)           - method of checking host availabitlity [none, pingandsnmp, snmpuptime, ping, pingorsnmp, snmpdesc, snmpgetnext].") do |avail|
        $options[:avail] = avail
      end

      $options[:pingmethod] = "tcp"
      opt.on("--pingmethod PINGMETHOD", "pingmethod (optional)      - if ping is the method of checking availabitlity , use this method to ckeck it [icmp, tcp, udp] (default tcp)") do |pingmethod|
        $options[:pingmethod] = pingmethod
      end

      $options[:pingport] = 23
      opt.on("--pingport PINGPORT", "pingport (optional)        - port to use for checking availabitlity method.") do |pingport|
        $options[:pingport] = pingport
      end

      $options[:pingretries] = 3
      opt.on("--pingretries PINGRETRIES", "pingretries (optional)     - the number of time to attempt to communicate with a host (default 1).") do |pingretries|
        $options[:pingretries] = pingretries
      end

      $options[:snmpversion] = 2
      opt.on("--snmpversion SNMPVERSION", "snmpversion (optional)     - snmp version [1, 2, 3] (default 2).") do |snmpversion|
        $options[:snmpversion] = snmpversion
      end

      $options[:snmpcommunity] = "{{ default_community }}"
      opt.on("--snmpcommunity SNMPCOMM", "snmpcommunity (optional)   - snmp community string for snmp v1 and snmp v2 (default public).") do |snmpcommunity|
        $options[:snmpcommunity] = snmpcommunity
      end

      $options[:snmpport] = 161
      opt.on("--snmpport SNMPPORT", "snmpport (optional)        - snmp port (default 161).") do |snmpport|
        $options[:snmpport] = snmpport
      end

      $options[:snmptimeout] = 500
      opt.on("--snmptimeout SNMPTIMEOUT", "snmptimeout (optional)     - snmp response time out (default 500).") do |snmptimeout|
        $options[:snmptimeout] = snmptimeout
      end

      $options[:snmpusername] = ""
      opt.on("--snmpusername SNMPUSER", "snmpusername (optional)    - snmp username for snmp v3.") do |snmpusername|
        $options[:snmpusername] = snmpusername
      end

      $options[:snmppassword] = ""
      opt.on("--snmppassword SNMPPASS", "snmppassword (optional)    - snmp password for snmp v3.") do |snmppassword|
        $options[:snmppassword] = snmppassword
      end

      $options[:snmpauthproto] = "MD5"
      opt.on("--snmpauthproto SNMPAUTHPRO", "snmpauthproto (optional)   - snmp privacy protocol for snmp v3 [DES, AES] (default MD5).") do |snmpauthproto|
        $options[:snmpauthproto] = snmpauthproto
      end

      $options[:snmpprivpass] = ""
      opt.on("--snmpprivpass SNMPPRIVPASS", "snmpprivpass (optional)   - snmp privacy passphrase for snmp v3.") do |snmpprivpass|
        $options[:snmpprivpass] = snmpprivpass
      end

      $options[:snmpprivproto] = "DES"
      opt.on("--snmpprivproto SNMPPRIPRO", "snmpprivproto (optional)   - snmp privacy protocol for snmp v3 [DES, AES].") do |snmpprivproto|
        $options[:snmpprivproto] = snmpprivproto
      end

      $options[:snmpcontext] = ""
      opt.on("--snmpcontext SNMPCONTEXT", "snmpcontext (optional)     - snmp context for snmp v3.") do |snmpcontext|
        $options[:snmpcontext] = snmpcontext
      end

      $options[:snmpmaxoids] = 10
      opt.on("--snmpmaxoids SNMPMAXOIDS", "snmpmaxoids (optional)     - the number of OID's that can be obtained in a single SNMP Get request.") do |snmpmaxoids|
        $options[:snmpmaxoids] = snmpmaxoids
      end

      opt.on_tail("--help","help") do
        puts opt_parser
        exit
      end
    end

    opt_parser.parse!

    ## check required parameters
    if $options[:description] == nil 
       #and $options[:help] == nil
      puts opt_parser
      exit
    #else
    #  abort("Failed: A description is required! use --help for more infos")
    end

# }}} CLASS PARAM

### CHAR to ID ####

    ### AVAILABILITY
    if $options[:avail] == "none"
      $avail = "0"
    elsif $options[:avail] == "pingandsnmp"
      $avail = "1"
    elsif $options[:avail] == "snmpuptime"
      $avail = "2"
    elsif $options[:avail]== "ping"
      $avail = "3"
    elsif $options[:avail] == "pingorsnmp"
      $avail = "4"
    elsif $options[:avail] == "snmpdesc"
      $avail = "5"
    elsif $options[:avail] == "snmpgetnext"
      $avail = "6"
    end

    ### PING METHOD
    if $options[:pingmethod] == "icmp"
      $pingmethod = "1"
    elsif $options[:pingmethod] == "udp"
      $pingmethod = "2"
    elsif $options[:pingmethod] == "tcp"
      $pingmethod = "3"
    end

  end

  def create
    templateid = `mysql --defaults-file=/root/.my.cnf -Nbe 'select id from {{ cacti_db_name }}.host_template WHERE name=\"#{$options[:template]}\"'`
    `php {{ cacti_cli }}/add_device.php --description=#{$options[:description]} --ip=#{$options[:ip]} --template=#{templateid}`

    # Set notes
    notes = $options[:notes]
    unless self.notes == notes
        self.notes = notes
    end

    # Set avail
    avail = $avail
    unless self.avail == avail
        self.avail = avail
    end

    # Set pingmethod
    ping_method = $pingmethod
    unless self.pingmethod == ping_method
        self.pingmethod = ping_method
    end

    # Set pingport
    ping_port = $options[:pingport]
    unless self.pingport == ping_port
        self.pingport = ping_port
    end

    # Set pingretries
    ping_retries = $options[:pingretries]
    unless self.pingretries == ping_retries
        self.pingretries = ping_retries
    end

    # Set snmpversion
    snmp_version = $options[:snmpversion]
    unless self.snmpversion == snmp_version
        self.snmpversion = snmp_version
    end

    # Set snmpcommunity
    snmp_community = $options[:snmpcommunity]
    unless self.snmpcommunity == snmp_community
        self.snmpcommunity = snmp_community
    end

    # Set snmpport
    snmp_port = $options[:snmpport]
    unless self.snmpport == snmp_port
        self.snmpport = snmp_port
    end

    # Set snmptimeout
    snmp_timeout = $options[:snmptimeout]
    unless self.snmptimeout == snmp_timeout
        self.snmptimeout = snmp_timeout
    end

    # Set snmpusername
    snmp_username = $options[:snmpusername]
    unless self.snmpusername == snmp_username
        self.snmpusername = snmp_username
    end

    # Set snmppassword
    snmp_password = $options[:snmppassword]
    unless self.snmppassword == snmp_password
        self.snmppassword = snmp_password
    end

    # Set snmpauthproto
    snmp_authproto = $options[:snmpauthproto]
    unless self.snmpauthproto == snmp_authproto
        self.snmpauthproto = snmp_authproto
    end

    # Set snmpprivpass
    snmp_privpass = $options[:snmpprivpass]
    unless self.snmpprivpass == snmp_privpass
        self.snmpprivpass = snmp_privpass
    end

    # Set snmpprivproto
    snmp_privproto = $options[:snmpprivproto]
    unless self.snmpprivproto == snmp_privproto
        self.snmpprivproto = snmp_privproto
    end

    # Set snmpcontext
    snmp_context = $options[:snmpcontext]
    unless self.snmpcontext == snmp_context
        self.snmpcontext = snmp_context
    end

    # Set snmpmaxoids
    snmp_maxoids = $options[:snmpmaxoids]
    unless self.snmpmaxoids == snmp_maxoids
        self.snmpmaxoids = snmp_maxoids
    end

    hostid = `mysql -NBe 'select id from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/.*/)[0]
    `php {{ cacti_cli }}/poller_reindex_hosts.php --id=#{hostid}`
  end

  def destroy

  end

  def ip
    ipRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
    hostnameRegex = "^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$";
    `mysql -NBe 'select hostname from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/#{ipRegex}|#{hostnameRegex}/)[0]
  end

  def ip=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET hostname=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def notes
    `mysql -NBe 'select notes from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/.*/)[0]
  end

  def notes=(value)
   `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET notes=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def avail
    `mysql -NBe 'select availability_method from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/\d+/)
  end

  def avail=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET availability_method=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def pingmethod
    `mysql -NBe 'select ping_method from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/\d+/)
  end

  def pingmethod=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET ping_method=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def pingport
    `mysql -NBe 'select ping_port from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/\d+/)
  end

  def pingport=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET ping_port=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`

  end

  def pingretries
    `mysql -NBe 'select ping_retries from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/\d+/)
  end

  def pingretries=(value)
    `mysql -NBe UPDATE {{ cacti_db_name }}.host SET ping_retries=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def snmpversion
    `mysql -NBe 'select snmp_version from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/0|1|2|3/)
  end

  def snmpversion=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET snmp_version=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def snmpcommunity
    `mysql -NBe 'select snmp_community from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/(?:[a-z][a-z0-9_]*)/)
  end

  def snmpcommunity=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET snmp_community=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def snmpport
    `mysql -NBe 'select snmp_port from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/.*/)[0]
  end

  def snmpport=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET snmp_port=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def snmptimeout
    `mysql -NBe 'select snmp_timeout from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/.*/)[0]
  end

  def snmptimeout=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET snmp_timeout=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def snmpusername
    `mysql -NBe 'select snmp_username from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/.*/)[0]
  end

  def snmpusername=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET snmp_username=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def snmppassword
    `mysql -NBe 'select snmp_password from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/.*/)[0]
  end

  def snmppassword=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET snmp_password=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def snmpauthproto
    `mysql -NBe 'select snmp_auth_protocol from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/.*/)[0]
  end

  def snmpauthproto=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET snmp_auth_protocol=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def snmpprivpass
    `mysql -NBe  'select snmp_priv_passphrase from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/.*/)[0]
  end

  def snmpprivpass=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET snmp_priv_passphrase=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def snmpprivproto
    `mysql -NBe 'select snmp_priv_protocol from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/.*/)[0]
  end

  def snmpprivproto=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET snmp_priv_protocol=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def snmpcontext
    `mysql -NBe  'select snmp_context from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/.*/)[0]
  end

  def snmpcontext=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET snmp_context=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def snmpmaxoids
    `mysql -NBe 'select max_oids from {{ cacti_db_name }}.host WHERE description=\"#{$options[:description]}\"'`.match(/.*/)[0]
  end

  def snmpmaxoids=(value)
    `mysql -NBe 'UPDATE {{ cacti_db_name }}.host SET max_oids=\"#{value}\" WHERE description=\"#{$options[:description]}\"'`
  end

  def exists?
    begin
      `php {{ cacti_cli }}/add_graphs.php  --list-hosts`.match(/#{options[:description]}/)
    rescue => e
      debug(e.message)
      return nil
    end
  end
end

Cacti_add_device.new.param
Cacti_add_device.new.create
