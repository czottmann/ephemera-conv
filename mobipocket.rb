require "sinatra"
require "dm-core"
require "mobi"
require "appengine-apis/memcache"


helpers do
  
  def new_exth(type, data)
    data += " "
    Mobi::ExtendedHeader.new( type, data.unpack("C*") )
  end
  
  
  def send_book(book)
    content_type 'application/octet-stream'
    response['Content-Disposition'] = 'inline'
    halt book
  end
  
end


get "/mobi" do
  CACHE.set("lol", "omg", 3)
  # puts request.env['REMOTE_ADDR'].inspect
  STDERR.puts mc.get("lol")
  
  "mobi"
end


post "/mobi" do
  unless params[:file] \
    && params[:file][:type] == "text/html" \
    && ( tmpfile = params[:file][:tempfile] ) \
    && ( name = params[:file][:filename] ) \
    && ( site = params[:site] ) \
    && ( title = params[:title] )
    halt 400, { "Content-Type" => "text/plain" }, "insufficient data"
  end

  key = [ request.env['REMOTE_ADDR'], name ].join("-")
  if book = CACHE.get(key)
    STDERR.puts "Cached request! FILE: #{name.inspect}; SITE: #{site}; TITLE: #{title}."
    send_book(book)
  else
    STDERR.puts "New request! FILE: #{name.inspect}; SITE: #{site}; TITLE: #{title}."

    while html = tmpfile.read(65536)
      mobi = Mobi.new
      mobi.content = html
      mobi.name = title
      mobi.title = title

      mobi.header.type = "NEWS" # "HTML"
      mobi.header.encoding = "UTF-8"
      mobi.header.extended_headers << new_exth( 100, site )
      mobi.header.extended_headers.each {|eh| mobi.header.exth_length += eh.length }
      mobi.header.exth_count = mobi.header.extended_headers.size

      io = StringIO.new
      mobi.write(io)
      io.seek(0)
      book = io.read

      CACHE.set(key, book, CACHE_TIME)
      send_book(book)
    end
  end
end





=begin

tmp_file = "_test/szde.html"
mobi_file = "_test/test.mobi"


mobi = Mobi.new
mobi.content = File.read(tmp_file)
mobi.name = "Politik kompakt: \"Afghanistan-Konflikt nicht zu gewinnen\""
mobi.title = mobi.name

mobi.header.type = "NEWS" # "HTML"
mobi.header.encoding = "UTF-8"
mobi.header.extended_headers << new_exth( 100, "sueddeutsche.de" )
mobi.header.extended_headers.each do |eh|
  mobi.header.exth_length += eh.length
end

mobi.header.exth_count = mobi.header.extended_headers.size

mobi.write_file(mobi_file)

=end