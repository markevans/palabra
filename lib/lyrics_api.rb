module LyricsApi
  class << self

    SITES = {
      search: 'http://search.azlyrics.com',
      main: 'http://www.azlyrics.com'
    }

    def search(query)
      html = with_site(:search) do |site|
        site.get(
          path: '/search.php',
          query: {
            q: query,
            p: 0, # page
            w: 'songs' # songs, not albums
          },
        ).body
      end
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
      path = url.sub(SITES[:main], '')
      html = with_site(:main) do |site|
        site.get(path: path).body
      end
      doc = Nokogiri::HTML(html)
      lyrics = doc.xpath('//comment()').detect{|e| e.text =~ /start.*lyrics/ }.parent.text.strip
      Song.new(
        title: doc.css('h2').text.sub('LYRICS','').strip.titleize,
        lyrics: lyrics,
        url: url,
        artist: doc.css('h2 ~ b').text.gsub('"','').titleize
      )
    end

    private

    def sites
      @sites ||= {}
    end

    def site(name)
      sites[name] ||= Excon.new(SITES[name])
    end

    def reload_site(name)
      sites.delete(name)
    end

    def with_site(name)
      begin
        yield site(name)
      rescue Excon::Errors::SocketError
        reload_site(name)
        yield site(name)
      end
    end
  end
end
