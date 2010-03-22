require "sinatra"
require "dm-core"
require "mobi"


helpers do
  
  def new_exth(type, data)
    data += " "
    Mobi::ExtendedHeader.new( type, data.unpack("C*") )
  end
  
  
  def send_book(book)
    content_type "application/octet-stream"
    response['Content-Disposition'] = "inline"
    halt book
  end
  
end


get "/mobi" do
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
    LOGGER.info("Cached request! FILE: #{name.inspect}; SITE: #{site}; TITLE: #{title}.")
    send_book(book)
  else
    LOGGER.info("New request! FILE: #{name.inspect}; SITE: #{site}; TITLE: #{title}.")

    while html = tmpfile.read(65536)
      mobi = Mobi.new
      mobi.content = html
      mobi.name = title
      mobi.title = title

      mobi.header.type = "NEWS"
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
