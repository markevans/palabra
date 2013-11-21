module LyricsApi
  class << self

    def search(query)
      html = Excon.get('http://search.azlyrics.com/search.php',
        query: {
          q: query,
          p: 0, # page
          w: 'songs' # songs, not albums
        },
      ).body
      doc = Nokogiri::HTML(html)
      doc.css('.sen').map do |node|
        song_link = node.css('a:first-child')
        Song.new(
          title: song_link.text.titleize,
          url: song_link.attr('href').value,
          artist: node.css('b').first.text.titleize
        )
      end
    end

    def song(url)
      html = Excon.get(url).body
      doc = Nokogiri::HTML(html)
      lyrics = doc.xpath('//comment()').detect{|e| e.text =~ /start.*lyrics/ }.parent.text.strip
      Song.new(
        title: doc.css('h2').text.sub('LYRICS','').strip.titleize,
        lyrics: lyrics,
        url: url,
        artist: doc.css('h2 ~ b').text.gsub('"','').titleize
      )
    end

  end
end
