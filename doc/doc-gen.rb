#!/usr/bin/env ruby

require 'inspec'
require 'erb'

MD_TEMPLATE_STRING = <<-MD.freeze
  # <%= @docs['name'] %>

  view [<%= @lib_name %>](../readme.md) resources list.

  ## Overview

  <%= @docs['name']%>. is locate [<%= @resource_file_md_path%>](<%= @resource_file_md_path%>)

  Opsman reference:
  <% for @item in @docs['api'] %>
  * <%= @item %>
  <% end %>

  ## Attributes/Methods
  <% for m in @docs['methods'] %>
  <% m.each do |k,v| %>
  * `<%= k %>` <%= v %>
  <% end %><% end %>

  ## Example

  ```ruby
  <%= @docs['example'] %>
  ```
MD

LIB_DIR = File.join(__dir__, '../libraries')

class MDTemplate
  def initialize(resource_file, md_file, lib_name)
    @resource_file = File.absolute_path(resource_file)
    @md_file = md_file
    @lib_name = lib_name

    content = File.open(resource_file).read
    @docs = content[/#{Regexp.escape('=begin')}(.*?)#{Regexp.escape('=end')}/m, 1]

    @resource_file_md_path = @resource_file.sub(File.absolute_path(File.join(__dir__, '../')), '')
    render
  end

  private

  def render
    if @docs.nil? || @docs.empty?
      puts "* Skipping #{@resource_file}"
      return false
    end
    @docs = YAML.safe_load(@docs)
    rendered_output = ERB.new(MD_TEMPLATE_STRING.gsub(/^  /, '')).result(binding)
    puts "* Render DOCS is defined for #{@md_file}"
    File.open(@md_file, 'w') { |file| file.write(rendered_output) }
  end
end

def loop_resources_dir(resource_dir, md_outputdir, lib_name)
  Dir.foreach(resource_dir) do |f|
    resource_file_path = File.join(resource_dir, f)
    next unless File.file?(resource_file_path) && f.end_with?('.rb')
    md_file_path = File.join(md_outputdir, f).sub('.rb', '.md')
    MDTemplate.new(resource_file_path, md_file_path, lib_name)
  end
end

## Loop over libaries
Dir.foreach(LIB_DIR) do |lib_name|
  lib_path = File.join(LIB_DIR, lib_name)
  next if lib_name == '.' || lib_name == '..' || !File.directory?(lib_path)
  md_outputdir = File.join(__dir__, lib_name)
  # For now generate only for opsman
  Dir.mkdir md_outputdir if lib_name == 'opsman' && !File.exist?(md_outputdir)
  loop_resources_dir(lib_path, md_outputdir, lib_name) if lib_name == 'opsman'
end