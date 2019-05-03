#!/usr/bin/env ruby

require 'inspec'
require 'erb'

MD_README_STRING = <<-MD.freeze
  # <%= lib_name %>

  Available resources:
  <% for @r in @rendered_resources %>
  * [<%= @r['key'] %>](<%= @r['path'] %>.md)
  <% end %>
MD

MD_TEMPLATE_STRING = <<-MD.freeze
  # <%= @docs['name'] %>

  view [<%= @lib_name %>](readme.md) resources list.

  ## Overview

  <%= @docs['name']%> is located in [<%= @resource_file_md_path%>](<%= @resource_file_md_path%>)
  <% if @docs.key?('api') %>Opsman reference:
  <% for @item in @docs['api'] %>
  * <%= @item %>
  <% end %><% end %>

  <% if @docs.key?('methods') %>## Attributes/Methods
  <% for m in @docs['methods'] %>
  <% m.each do |k,v| %>
  * `<%= k %>` <%= v %>
  <% end %><% end %><% end %>

  <% if @docs.key?('example') %>## Example

  ```ruby
  <%= @docs['example'] %>
  ```<% end %>
MD

SPEC_TEMPLATE = <<-MD.freeze
  <% if @docs.key?('example') -%>
  <%= @docs['example'] -%>
  <% end -%>
MD

LIB_DIR = File.join(__dir__, '../libraries')

class MDTemplate
  def initialize(resource_file, md_file, rb_example_path, lib_name)
    @resource_file = File.absolute_path(resource_file)
    @md_file = md_file
    @rb_example_path = rb_example_path
    @lib_name = lib_name

    content = File.open(resource_file).read
    @docs = content[/#{Regexp.escape('=begin')}(.*?)#{Regexp.escape('=end')}/m, 1]

    @resource_file_md_path = @resource_file.sub(File.absolute_path(File.join(__dir__, '../')), '')
  end

  def render
    if @docs.nil? || @docs.empty?
      puts "* Skipping #{@resource_file}"
      return false
    end

    @docs = YAML.safe_load(@docs)
    write_files
    @docs['name']
  end

  def write_files
    puts "* Rendering #{@md_file}"
    md_rendered_output = ERB.new(MD_TEMPLATE_STRING.gsub(/^  /, '')).result(binding)
    File.open(@md_file, 'w') { |file| file.write(md_rendered_output) }
    puts "* Rendering #{@rb_example_path}"
    rb_rendered_output = ERB.new(SPEC_TEMPLATE.gsub(/^  /, ''), nil, '-').result(binding)

    File.open(@rb_example_path, 'w') { |file| file.write(rb_rendered_output) }
  end
end

def render_readme(md_outputdir, lib_name)
  rendered_output = ERB.new(MD_README_STRING.gsub(/^  /, '')).result(binding)
  File.open(File.join(md_outputdir, 'readme.md'), 'w') { |file| file.write(rendered_output) }
end

def loop_resources_dir(resource_dir, md_outputdir, rb_outputdir, lib_name)
  @rendered_resources = []
  Dir.foreach(resource_dir) do |f|
    resource_file_path = File.join(resource_dir, f)
    next unless File.file?(resource_file_path) && f.end_with?('.rb')
    md_file_path = File.join(md_outputdir, f).sub('.rb', '.md')
    md = MDTemplate.new(resource_file_path, md_file_path, File.join(rb_outputdir, f), lib_name)
    rendered = md.render
    @rendered_resources.push('key' => rendered, 'path' => f.sub('.rb', '')) if rendered
  end
  render_readme(md_outputdir, lib_name)
end

## Loop over libaries
Dir.foreach(LIB_DIR) do |lib_name|
  lib_path = File.join(LIB_DIR, lib_name)
  next if lib_name == '.' || lib_name == '..' || !File.directory?(lib_path)
  md_outputdir = File.join(__dir__, lib_name)
  rb_example_outputdir = File.join(__dir__, '../test/examples/', lib_name, 'controls')
  # For now generate only for opsman
  Dir.mkdir md_outputdir if lib_name == 'opsman' && !File.exist?(md_outputdir)
  loop_resources_dir(lib_path, md_outputdir, rb_example_outputdir, lib_name) if lib_name == 'opsman'
end
