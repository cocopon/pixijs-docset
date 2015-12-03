#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'
# rubygems
require 'nokogiri'
require 'sqlite3'
# local
require_relative 'lib/environment.rb'
require_relative 'lib/docset_builder.rb'
require_relative 'lib/pixi.rb'

if __FILE__ == $0
  script_home = File.expand_path(File.dirname(__FILE__))

  env = Environment.new()
  env.repos_dir = File.join(script_home, 'tmp')
  env.repos_url = "https://github.com/pixijs/docs"
  env.docset_dir = File.join(script_home, 'Pixijs.docset')
  env.template_dir = File.join(script_home, 'template')

  opt = DocsetBuilderOption.new()
  opt.html_modifier = PixiHtmlModifier
  opt.doc_parser = PixiDocumentParser

  builder = DocsetBuilder.new(env, opt)
  builder.build()
end
