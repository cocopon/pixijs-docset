require_relative 'document_parser.rb'
require_relative 'file_modifler.rb'

class PixiHtmlModifier < FileModifier
  def self.modify(path)
    lines = []
    File.open(path) do |f|
      while line = f.gets()
        lines << line
      end
    end

    # Inject additional CSS
    lines.each_index do |index|
      if lines[index].strip() == '</head>'
        lines.insert(index, '<link rel="stylesheet" href="./docset.css"/>')
        break
      end
    end

    File.open(path, 'w') do |f|
      f.write(lines.join(''))
    end
  end
end

class PixiDocumentParser < DocumentParser
  TYPE_HASH = {
    'Class' => 'Class',
    'Namespace' => 'Namespace',
  }

  def self.each_entry(path)
    html = nil
    File.open(path) do |f|
      html = f.read()
    end

    doc = Nokogiri::HTML.parse(html, nil)

    # Class/Namespace
    if doc.css('title').text =~ /(\w+):\s?(.+)$/
      type = TYPE_HASH[$1]
      if type != nil
        name = File.basename($2, '.js')
        yield name, type, nil
      end
    end

    # Method
    doc.css('.methods.itemMembers li').each do |node|
      anchor = node.css('a')
      name = anchor.text.strip()
      path = anchor.attribute('href').to_s()

      yield name, 'Method', path
    end
  end
end
