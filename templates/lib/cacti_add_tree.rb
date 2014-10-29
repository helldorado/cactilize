#!/usr/bin/env ruby

# 2014 ::  Abdoul Bah <devops@helldorado.info>
# Add Tree Ruby wrapper for the cacti cli API.
#
# This program is free software. It may be redistributed and/or modified under
# the terms of the GPL version 2 (or later) or the Ruby licence.


class Cacti_add_tree

  require 'optparse'

  def param
    

    $options = {}

    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: cacti.add_graph.rb PARAMETERS [VALUES]"
      opt.separator  ""
      opt.separator  "Parameters:"

      opt.on("--name TITLE", "title (required)     - the name of the tree when creating new tree
                                                          - the name of the desired header when adding new header node.
                                                          - the name of host to be added when adding new host node.
                                                          - the name of graph to be added when adding new host node.") do |name|
        $options[:name] = name
      end

      opt.on("--type TYPE", "type (required)      - The type of object that will be added [tree, node]
                                                            * tree - when adding a new tree
                                                            * node - when adding a new node") do |type|
        $options[:type] = type
      end

      opt.on("--nodetype NODETYPE", "nodetype (required for nodes) - The type of node you are adding [header, host, graph]") do |nodetype|
          $options[:nodetype] = nodetype
      end

      $options[:tree] = ""
      opt.on("--tree TREE", "tree  (required for nodes)    - The name of the tree the node will be added to.") do |tree|
        $options[:tree] = tree
      end

      $options[:parentnode] = ""
      opt.on("--parentnode PARENTNODE", "parentnode (optional)         - The name of the node the new node will be added under. If this is missing the new node will be added under the specified tree.") do |parentnode|
        $options[:parentnode] = parentnode
      end

      opt.on("--help","help") do
        puts opt_parser
      end

    end
    opt_parser.parse!
  end 


  def create

    if $options[:type] == 'tree'
      `php {{ cacti_cli }}/add_tree.php --type=tree --name=#{$options[:name]}`
    else

      treeid = `mysql -NBe  'select id from {{ cacti_db_name }}.graph_tree WHERE name=\"#{$options[:tree]}\"'`.match(/.*/)[0]

      parentid = `mysql -NBe 'select id from {{ cacti_db_name }}.graph_tree_items WHERE title=\"#{$options[:parentnode]}\"'`.match(/.*/)[0]

      if $options[:nodetype] == "header"

        if $options[:parentnode] == ''

          `php {{ cacti_cli }}/add_tree.php --type=node --tree-id=#{treeid} --node-type=header --name=#{$options[:name]}`
        else
          `php {{ cacti_cli }}/add_tree.php --type=node --tree-id=#{treeid} --node-type=header --name=#{$options[:name]} --parent-node=#{parentid}`
          puts $options[:name]
        end

      elsif $options[:nodetype] == 'host'

        hostid = `mysql -NBe 'select id from {{ cacti_db_name }}.host WHERE description=\"#{$options[:name]}\"'`.match(/.*/)[0]

        if $options[:parentnode] == ''
          `php {{ cacti_cli }}/add_tree.php --type=node --tree-id=#{treeid} --node-type=host --host-id=#{hostid}`
        else
          `php {{ cacti_cli }}/add_tree.php  --type=node --tree-id=#{treeid} --node-type=host --host-id=#{hostid} --parent-node=#{parentid}`
        end

      elsif $options[:nodetype] == 'graph'
        graphid = `mysql -NBe 'select local_graph_id from {{ cacti_db_name }}.graph_templates_graph WHERE title_cache=\"#{$options[:name]}\"'`.match(/.*/)[0]

        if $options[:parentnode] == ''
          `php {{ cacti_cli }}/add_tree.php --type=node --tree-id=#{treeid} --node-type=graph --graph-id=#{graphid}`
        else
          `php {{ cacti_cli }}/add_tree.php --type=node --tree-id=#{treeid} --node-type=graph --graph-id=#{graphid} --parent-node=#{parentid}`
        end

      end

    end

  end

  def destroy
  
  end

  def type
    treeid = `mysql -NBe 'select id from {{ cacti_db_name }}.graph_tree WHERE name=\"#{$options[:name]}\"'`.match(/\A[0-9]+/)
   
    if treeid
      return 'tree'
    else 
      return 'node'
    end

  end

  def type=(value)
  end

  def exists?
    begin

      if $options[:type] == :tree

        `mysql -NBe 'select id from {{ cacti_db_name }}.graph_tree WHERE name=\"#{$options[:name]}\"'`.match(/\A[0-9]+/)

      elsif
        parentid = `mysql -NBe 'select id from {{ cacti_db_name }}.graph_tree_items WHERE title=\"#{$options[:parentnode]}\"'`.match(/.*/)[0]

        if options[:nodetype] == 'header'
          
          `mysql -NBe 'select id from {{ cacti_db_name }}.graph_tree_items WHERE title=\"#{$options[:name]}\"'`.match(/\A[0-9]+/)

        elsif $options[:nodetype] == 'host'

          hostid = `mysql -NBe 'select id from {{ cacti_db_name }}.host WHERE description=\"#{$options[:name]}\"'`.match(/.*/)[0]

          `mysql -NBe 'select id from {{ cacti_db_name }}.graph_tree_items WHERE host_id=\"#{hostid}\"'`.match(/\A[0-9]+/)

        elsif options[:nodetype] == 'graph'

          graphid = `mysql -NBe 'select local_graph_id from {{ cacti_db_name }}.graph_templates_graph WHERE title_cache=\"#{$options[:name]}\"'`.match(/.*/)[0]

          `mysql -NBe 'select id from {{ cacti_db_name }}.graph_tree_items WHERE local_graph_id=\"#{graphid}\"'`.match(/\A[0-9]+/)

        end

      end
    rescue => e
      debug(e.message)
      return nil
    end
  end

end


Cacti_add_tree.new.param
Cacti_add_tree.new.create
