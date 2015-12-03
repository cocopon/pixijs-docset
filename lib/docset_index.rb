class DocsetIndex
  def initialize(path)
    SQLite3::Database.open(path) do |db|
      @db = db
      yield self
    end
    @db = nil
  end

  def create()
    sql = <<-SQL
      CREATE TABLE searchIndex(
        id INTEGER PRIMARY KEY,
        name TEXT,
        type TEXT,
        path TEXT
      );
    SQL
    @db.execute(sql)
  end

  def add(name, type, path)
    sql = <<-SQL
      INSERT OR IGNORE INTO
        searchIndex(name, type, path)
        VALUES(?, ?, ?)
    SQL
    @db.execute(sql, name, type, path)
  end
end
