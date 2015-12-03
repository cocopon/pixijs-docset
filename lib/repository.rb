class Repository
  def initialize(home_dir)
    @home = home_dir
  end

  def home_dir()
    return @home
  end

  def target?(filename)
    return !['.', '..', '.git'].include?(filename)
  end

  def each_file()
    Dir::foreach(@home) do |filename|
      if !target?(filename)
        next
      end

      yield filename
    end
  end
end
