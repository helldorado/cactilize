#!/usr/bin/env ruby
# 2014 ::  Abdoul Bah <devops@helldorado.info>
# Add Graph Ruby wrapper for the cacti cli API.
#
# This program is free software. It may be redistributed and/or modified under
# the terms of the GPL version 2 (or later) or the Ruby licence.

class Cacti_add_graph
  require 'optparse'

  def param

    $options = {}

    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: cacti.add_graph.rb PARAMETERS [VALUES]"
      opt.separator  ""
      opt.separator  "Parameters:"

      opt.on("--name TITLE", "description (required)     - the name of the options.") do |name|
        $options[:name] = name
      end

      opt.on("--device ","Device (required)              - The name of the device the graph will be added to.") do |device|
        $options[:device] = device
      end

      opt.on("--graphtype GRAPHTYPE", "graphtype (required)  - 'cg' graphs are for things like CPU temp/fan speed, while 'ds' graphs are for data-source based graphs (interface stats etc.)") do |graphtype|
          $options[:graphtype] = graphtype
      end

      $options[:graphtemplate] = ""
      opt.on("--graphtemplate GRAPH TEMPLATE", "graphtemplate (required) - General information about this host.") do |graphtemplate|
        $options[:graphtemplate] = graphtemplate
      end

      $options[:snmpquery] = ""
      opt.on("--snmpquery SNMPQUERY", "snmpquery (required for ds graphs) - name of Data Query") do |snmpquery|
        $options[:snmpquery] = snmpquery
      end

      $options[:snmpquerytype] = ""
      opt.on("--snmpquerytype SNMPQUERYTYPE", "snmpquerytype (required for ds graphs) - name of Associated Graph Template to be used") do |snmpquerytype|
        $options[:snmpquerytype] = snmpquerytype
      end

      $options[:snmpfield] = ""
      opt.on("--snmpfield SNMPFIIELD", "snmpfield (required for ds graphs) - name of the snmp field that will be used to in combination with the snmp valued to determine witch graph will be freated.") do |snmpfield|
        $options[:snmpfield] = snmpfield
      end

      $options[:snmpvalue] = 1
      opt.on("--snmpvalue PINGRETRIES", "snmpvalue (required for ds graphs) - name of the snmp value that will determine which graph will be created.") do |snmpvalue|
        $options[:snmpvalue] = snmpvalue
      end

      opt.on("--help","help") do
        puts opt_parser
      end

    end
    opt_parser.parse!
  end

  def create
    hostid = `mysql -NBe 'select id from {{ cacti_db_name }}.host WHERE description=\"#{$options[:device]}\"'`.match(/.*/)[0]
    templateid = `mysql -NBe 'select id from {{ cacti_db_name }}.graph_templates WHERE name=\"#{$options[:graphtemplate]}\"'`.match(/.*/)[0]

    if $options[:graphtype] == "cg"
    `php {{ cacti_cli }}/add_graphs.php --host-id=#{hostid} --graph-type=#{$options[:graphtype]} --graph-template-id=#{templateid}`
    
    else
      snmpqueryid = `mysql -NBe 'select id from {{ cacti_db_name }}.snmp_query WHERE name=\"#{$options[:snmpquery]}\"'`.match(/.*/)[0]
      snmpquerytypeid= `mysql -NBe 'select id from {{ cacti_db_name }}.snmp_query_graph WHERE name=\"#{$options[:snmpquerytype]}\"'`.match(/.*/)[0]

      `php {{ cacti_cli }}/add_graphs.php --host-id=#{hostid} --graph-type=#{$options[:graphtype]} --graph-template-id=#{templateid} --snmp-query-id=#{snmpqueryid} --snmp-query-type-id=#{snmpquerytypeid} --snmp-field=#{$options[:snmpfield]} --snmp-value=#{$options[:snmpvalue]}`
    end
  end

  def destroy

  end

  def graphtype
      hostid = `mysql -NBe 'select id from {{ cacti_db_name }}.host WHERE description=\"#{$options[:device]}\"'`.match(/.*/)[0]
      templateid = `mysql -NBe 'select id from {{ cacti_db_name }}.graph_templates WHERE name=\"#{$options[:graphtemplate]}\"'`.match(/.*/)[0]

      result = `mysql -NBe 'select * from {{ cacti_db_name }}.host_graph WHERE host_id=\"#{hostid}\" and graph_template_id=\"#{templateid}\"'`.match(/\A[0-9]+/)

      if result == nil
        return :ds
      else
        return :cg
      end
  end

  def graphtype=(value)

  end

  def exists?
    begin
    
      hostid = `mysql -NBe 'select id from {{ cacti_db_name }}.host WHERE description=\"#{$options[:device]}\"'`.match(/.*/)[0]
      templateid = `mysql -NBe 'select id from {{ cacti_db_name }}.graph_templates WHERE name=\"#{$options[:graphtemplate]}\"'`.match(/.*/)[0]
 
      if $options[:graphtype] == "cg"
        `mysql -NBe 'select id from {{ cacti_db_name }}.graph_local WHERE host_id=\"#{hostid}\" and graph_template_id=\"#{templateid}\"'`.match(/\A[0-9]+/)
      else
        snmpqueryid = `mysql -NBe 'select id from {{ cacti_db_name }}.snmp_query WHERE name=\"#{$options[:snmpquery]}\"'`.match(/.*/)[0]

        snmpindex = `mysql -NBe 'select snmp_index from {{ cacti_db_name }}.host_snmp_cache WHERE host_id=\"#{hostid}\" and snmp_query_id=\"#{snmpqueryid}\" and field_name=\"#{$options[:snmpfield]}\"  and field_value=\"#{$options[:snmpvalue]}\"'`.match(/\A[0-9]+/)[0]

        `mysql -NBe 'select id from {{ cacti_db_name }}.graph_local WHERE host_id=\"#{hostid}\" and graph_template_id=\"#{templateid}\" and snmp_index=\"#{snmpindex}\"'`.match(/\A[0-9]+/)
      end

    rescue => e
      debug(e.message)
      return nil
    end
  end
end
Cacti_add_graph.new.param
Cacti_add_graph.new.create
