require_relative 'docset.rb'
require_relative 'docset_index.rb'
require_relative 'spinner.rb'
require_relative 'repository.rb'

class DocsetBuilderOption
  attr_accessor :html_modifier
  attr_accessor :css_modifier
  attr_accessor :doc_parser

  def DocsetBuilderOption()
    @html_modifier = nil
    @css_modifier = nil
    @doc_parser = nil
  end
end

class DocsetBuilder
  def initialize(env, option)
    @env = env
    @repos = Repository.new(env.repos_dir)
    @docset = Docset.new(env.docset_dir)
    @html_modifier = option.html_modifier
    @css_modifier = option.css_modifier
    @doc_parser = option.doc_parser
  end

  def build()
    clone_repos()
    copy_repos_files()
    copy_template_files()
    modify_files()
    create_index()
  end

  def clone_repos()
    if !File.exist?(@env.repos_dir)
      puts('Cloning repository...')
      system("git clone #{@env.repos_url} #{@env.repos_dir}")
      puts('done.')
    else
      puts('Updating repository...')
      Dir.chdir(@env.repos_dir) do
        system('git reset --hard')
        system('git pull')
      end
      puts('done.')
    end
  end

  def copy_repos_files()
    if !File.exist?(@docset.documents_dir)
      puts("Creating #{@docset.documents_dir}...")
      FileUtils.mkdir_p(@docset.documents_dir)
    else
      puts("Cleaning #{@docset.documents_dir}...")
      FileUtils.rm_r(
        Dir::glob(File.join(@docset.documents_dir, '*')),
        :secure => true
      )
    end
    puts('done.')

    spinner = Spinner.new()
    spinner.init('Copying repository files...')
    @repos.each_file() do |filename|
      src_path = File.join(@repos.home_dir, filename)
      dst_path = File.join(@docset.documents_dir, filename)

      FileUtils.cp_r(src_path, dst_path)
      spinner.spin()
    end
    spinner.finish('done.')
  end

  def copy_template_files()
    print('Copying template files...')

    # Copy additional CSS
    src_path = File.join(@env.template_dir, 'docset.css')
    dst_path = File.join(@docset.documents_dir, 'docset.css')
    FileUtils.cp(src_path, dst_path)

    # Copy Info.plist
    src_path = File.join(@env.template_dir, 'Info.plist')
    dst_path = File.join(@docset.contents_dir, 'Info.plist')
    FileUtils.cp(src_path, dst_path)

    puts('done.')
  end

  def modify_files()
    spinner = Spinner.new()

    spinner.init('Formatting HTML files...')
    if @html_modifier != nil
      @docset.each_document('html') do |path|
        @html_modifier.modify(path)
        spinner.spin()
      end
    end
    spinner.finish('done.')

    spinner.init('Formatting CSS files...')
    if @css_modifier != nil
      @docset.each_document('css') do |path|
        @css_modifier.modify(path)
        spinner.spin()
      end
    end
    spinner.finish('done.')
  end

  def create_index()
    path = @docset.dsidx_path
    if File.exist?(path)
      FileUtils.rm(path)
    end

    DocsetIndex.new(path) do |dsi|
      spinner = Spinner.new()
      spinner.init('Creating docset index...')

      dsi.create()

      # Add method entries
      doc_pathname = Pathname.new(@docset.documents_dir)
      @docset.each_document('html') do |html_path|
        html_pathname = Pathname.new(html_path)
        rel_path = html_pathname.relative_path_from(doc_pathname).to_s()

        @doc_parser.each_entry(html_path) do |name, type, opt_path|
          entry_path = (opt_path != nil) ? opt_path : rel_path
          dsi.add(name, type, entry_path)
          spinner.spin()
        end
      end

      spinner.finish('done.')
    end
  end
end
