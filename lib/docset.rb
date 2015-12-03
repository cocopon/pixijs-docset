class Docset
  def initialize(home_dir)
    @home = home_dir
  end

  def contents_dir()
    return File.join(@home, 'Contents')
  end

  def resources_dir()
    return File.join(contents_dir, 'Resources')
  end

  def documents_dir()
    return File.join(resources_dir, 'Documents')
  end

  def dsidx_path()
    return File.join(resources_dir, 'docSet.dsidx')
  end

  def each_document(extension)
    basename = extension ? "*.#{extension}" : "*"
    Dir::glob(File.join(documents_dir, '**', basename)) do |path|
      yield path
    end
  end
end
