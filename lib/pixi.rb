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

  def self.each_entry(path, rel_path)
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
        yield name, type, rel_path
      end
    end

    # Property
    members_h = (doc.css('h3').find {|node| node.text == 'Members'})
    if members_h != nil
      members_container = members_h.next_element
      members_container.css('h4').each do |node|
        name = node.xpath('text()').text.strip()
        hash = node.attribute('id').to_s()
        yield name, 'Property', "#{rel_path}##{hash}"
      end
    end

    # Method
    methods_h = (doc.css('h3').find {|node| node.text == 'Methods'})
    if methods_h != nil
      methods_container = methods_h.next_element
      methods_container.css('h4').each do |node|
        name = node.xpath('text()').text.strip()
        hash = node.attribute('id').to_s()
        yield name, 'Method', "#{rel_path}##{hash}"
      end
    end
  end
end
