module LivescoreParser
  class Parser

    def initialize
      @agent = Mechanize.new
    end

    # Runs dynamic-sprites command.
    #
    def run
      LivescoreParser.selected_pages.map do |name, options|
        data = download(options['url'])
        { name: name, path: options['path'], data: data } unless data.nil?
      end.compact
    end

    private

    def download(url)
      page = Nokogiri::HTML(@agent.get(url).body)
      data = build_hash page.css(".content tr")
      if data.empty?
        puts "Missing data"
        return nil
      else
        return data
      end
    end

    # convert nokogiri html data to handy hash structure
    def build_hash(data)
      index = 0
      data.map do |row|
        if row.css('td').any?
          index += 1
          {
            wiersz: index,
            czas: row.css('td')[0].text.strip,
            gracz1: row.css('td')[1].text.strip,
            wynik1: row.css('td')[2].text.strip.match(/^[0-9\?]+/).to_s,
            gracz2: row.css('td')[3].text.strip,
            wynik2: row.css('td')[2].text.strip.match(/[0-9\?]+$/).to_s,
            kraj: @country
          }
        else
          @country = row.css('.league').text.strip
          next
        end
      end.compact
    end
  end
end
