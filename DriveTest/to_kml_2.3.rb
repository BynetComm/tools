# copy and paste the code and save as a ruby file (.rb extension). Works with ruby 1.8.7 (default version on Snow Leopard).
# With the CSV file containing the data, run the script with the following syntax:
# ruby to_kml.rb <clientname> <filename> [optional write mode (w,wb,a+)] [optional output filename]
# So if this was for ATS Group, and the file was locations.csv:
# ruby to_kml.rb ATS_Group locations.csv
#
# CSV Formatting requirements:
#
# Must contain columns: name, address, lat, lng. You may leave other columns in there if you wish. There is no downfall to doing so.
# To get lat/lng values, use the address or zipcode data that you have, and paste it into the form here: out2launchdigital.com/pagetorrent/geocoder/
# Once the page linked is done, it will respond with an alert message. It will take time, as it runs a request to google's api every few seconds.
RUBYOPT="-W0"

require 'csv'
require 'optparse'
require 'rgeo'

DOCTYPE = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
           <kml xmlns=\"http://www.opengis.net/kml/2.2\"\n
		   xmlns:gx=\"http://www.google.com/kml/ext/2.2\"\n
		   xmlns:kml=\"http://www.opengis.net/kml/2.2\"\n
		   xmlns:atom=\"http://www.w3.org/2005/Atom\">"

 @options = Hash.new

 @options[:client_name] = 'SEGEV';
 @options[:inputfile] = 'c:\temp\output16_2.csv';
 @options[:writemode] = 'w';
 @options[:myfilename] = 'c:\temp\output16_2.kml'; 
 @options[:usetimestamp] = true; 

 VERSION = "2.2"
 DEBUG = false   
 DISPLAY_ZERO_RSS = true
 
 opts = OptionParser.new do |opts|
    opts.banner = 'To KML'

    opts.on("-c", "--clientname [client_name]", "Client name to add to header") do |client_name|
      @options[:client_name] = client_name
    end

    opts.on("-i", "--inputfile [inputfile]", "File with full path to translate") do |inputfile|
      @options[:inputfile] = inputfile
    end
    
	opts.on("-w", "--writemode [option]", "append (a+) or overwrite (w) new output file") do |wm|
      @options[:writemode] = wm
    end
		
	opts.on("-o", "--outputfile [filename]", "Target File with path to create") do |outputfilename|
      @options[:myfilename] = outputfilename
    end
	
	opts.on("-u", "--usetimestamp true/false", "should the kml have timestamps or not") do |ts|
      @options[:usetimestamp] = ts
    end
	
	opts.on("-h", "--help", "-?", "--?", "Get Help") do |help|
      puts("help ..... call oz 052-5528022")
	  puts opts.help
    end
  
end		   



  if ARGV.length == 0
    puts opts.help 
  else
   opts.parse!(ARGV)  
 end
 
@@unused_rows = Array.new [];
@@labelColors=Array['000000', '111111' , '222222' , '333333' , '444444', '555555' , '666666' , '777777' , '888888',
                  '999999', 'AAAAAA'  , 'BBBBBB', 'CCCCCC' , 'DDDDDD' ,'EEEEEE' , 'FFFFFF']
@@labelsIndex = Hash.new {};
  

Colors=Array['FFFFFF', '10FF00' , '00FF00', '00FF0F',	'00FF1F',	'00FF3F',	'00FF5F',	'00FF7F',	'00FF9F',	'00FFBF',
	'00FFDF',	'00EFFF',	'00CFFF',	'00AFFF',	'008FFF',	'006FFF',	'004FFF','002FFF','000000','000000']

#@rss_styles = Array.new [20, -20, -44 ,-47, -50,-53,-56,-59,-62, -65,-76,-79,-82,-85, -88,-90,-121] 
@rss_styles = Array.new [ -30,-40 ,-45,-50,-60,-62 ,-65,-68,-70,-73,-75,-78,-81,-83 ,-85,-90,-95,-98, -121 ]   
@@rss_styles = @rss_styles
unless File.exists?(@options[:inputfile])
  raise 'File not found'
end
name, address, timestamp, lat, lng, client  ,rss_BH_AIR_MaxRSL, rss_BH_AIR_MinRSL , state, connected_to_hbs ,ping_to_remote = nil, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil

def file_is_valid(row)
  if ((row==nil) || (row =="")) then
	return false
  end
  #row = row.collect {|c| c.downcase }
 # puts row;
 # puts row.include?('name'); 
 # puts row.include?('address'); 
 # puts row.include?('lat');
 # puts row.include?('lng');
 # puts row.include?('timestamp');
 puts ("valdite header")
 row.include?('name') && row.include?('address') && row.include?('lat') && row.include?('lng') && row.include?('timestamp') && row.include?('BH_AIR_MinRSL') && row.include?('BH_AIR_MaxRSL') && row.include?('state') && row.include?('Connected_to_HBS ') && row.include?('ping to remote')
 
end

def humanize(str)
  str.gsub(/\-/, ' ')
end

 @locations = []

class Location
  attr_accessor :name, :address, :lat, :lng, :client, :timestamp ,:BH_AIR_MinRSL, :BH_AIR_MaxRSL , :state , :connected_to_HBS , :ping_to_remote
  
  
  def initialize(myoptions = {})

    if myoptions.size > 0
      	
      @name = myoptions[:name]
      @address = myoptions[:address]
      @lat = myoptions[:lat]
      @lng = myoptions[:lng]
      @client = myoptions[:client]
      @timestamp = myoptions[:timestamp]
	  @rss_BH_AIR_MinRSL = myoptions[:BH_AIR_MinRSL]
	  @rss_BH_AIR_MaxRSL = myoptions[:BH_AIR_MaxRSL]
      @state = myoptions[:state]||""
      @_connected_to_HBS = myoptions[:connected_to_HBS]||"None"
      @ping_to_remote = myoptions[:ping_to_remote]
      if (@address == "0") && not( @ping_to_remote == "0") then
	     @address = @rss_BH_AIR_MaxRSL
	  end
  
    end
  
  def connected_to_HBS
     return "#{@_connected_to_HBS}"
  end  

  def timestamp
    return self.timestamp
  end  

  def address
    return  "#{@address}"
  end  
  
  def lat
  	return  "#{@lat}"
  end	

 def lng
  	return  "#{@lng}"
  end


  def to_kml
begin 
    uts = true 
    displayname = false
    displayrss = true
    if !(@@labelsIndex.has_key?("#{@_connected_to_HBS.to_s}")) then
      @@labelsIndex.store("#{@_connected_to_HBS.to_s}" , @@labelsIndex.length+1 );
    end  
    out =" <Placemark>\n"+
     "  <styleUrl>#label_color#{@@labelsIndex[@_connected_to_HBS.to_s]}</styleUrl>\n" +
     #   "   <LabelStyle>\n"+
     #   "     <color>#FF#{@@labelColors[@@labelsIndex[@_connected_to_HBS.to_s]]}</color>\n"+
     #   "   </LabelStyle>\n"+ 
        "   <name>"
        out +=  "#{@name}" unless !displayname
		if !(@timestamp==nil ) then
         out += @timestamp[11..18]||"" unless (!uts) 
    #     out +=  "[#{@rss_BH_AIR_MinRSL}]" unless !displayrss
	     out +=  "[#{@address}]" unless !displayrss
		end
    if !(@_connected_to_HBS==nil ) then
        out +="BST: #{ @_connected_to_HBS[9]=="-" ? @_connected_to_HBS[8] : @_connected_to_HBS[8..9]}"   #postion

    else
      out +="BST: None"
    end 
    out += "</name>\n"  
	  if uts then
        out += "<TimeStamp>#{@timestamp}</TimeStamp>\n" 
	  end	
	out += "   <visibility>1</visibility>\n"+
		#"   <open>1</open>\n" +
		#"<LookAt>\n" +
		#"	<longitude>#{@lng}</longitude>\n" +
		#"	<latitude>#{@lat}</latitude>\n"+
		#"	<altitude>0</altitude>\n"+
		#"	<heading>0</heading>\n"+
		#"	<tilt>0</tilt>\n"+
		#"	<altitudeMode>relativeToGround</altitudeMode>\n" +
		#"	<gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>\n"+
		#"</LookAt>\n" +
		""
      index=0;
      style_index ='';
#	  rss_styles = Array.new [ -30,-50,-60 ,-65,-68,-70,-73,-75,-78,-79,-80,-81,-83 ,-84,-85,-90,-95,-105,-121 ]  
      @@rss_styles.each do |rss_level|
        #puts ("#{@address.to_i} < #{@rss_styles[index].to_i} = #{(@address.to_i < @rss_styles[index].to_i)}")
    #    if @rss_BH_AIR_MinRSL.to_i <= @rss_styles[index].to_i then 
	    if @address.to_i <= @@rss_styles[index].to_i then 
          style_index = (index==0)? '': index.to_s;
        end
	    index+=1
      end
    if @state == nil then
       #puts   self.inspect
         if @ping_to_remote.strip == "0" then
            # out += "  <styleUrl>#msn_forbidden#{style_index}</styleUrl>\n"
            out += "  <styleUrl>#msn_forbidden</styleUrl>\n"
         else 
           out += " <styleUrl>#msn_shaded_dot#{style_index}</styleUrl>\n"
         end  
    else   
      if @state.strip == "HSU_REGISTERED" then  
        out += "	<styleUrl>#msn_shaded_dot#{style_index}</styleUrl>\n"
      else
        #puts @state.strip
        if @ping_to_remote.strip == "0" then
          out += "  <styleUrl>#msn_forbidden</styleUrl>\n"
        else  
          out += "  <styleUrl>#msn_forbidden#{style_index}</styleUrl>\n"
        end
      end
    end    
#    out += "	<description><![CDATA[RSSI=#{@rss_BH_AIR_MinRSL||'N/A'}<br>\nPing to Remote=#{@ping_to_remote||''}<br>\nState=#{@state==nil ? '' : @state.strip}<br>\nConnected_to_HBS=#{@_connected_to_HBS||''}"+
	
    out += "	<description><![CDATA[RSSI=#{@address||'N/A'}<br>\nPing to Remote=#{@ping_to_remote||''}<br>\nState=#{@state==nil ? '' : @state.strip}<br>\nConnected_to_HBS=#{@_connected_to_HBS||''}"+

         "]]></description>\n" +
    "<ExtendedData>\n" +
      '<Data name="RSS_BH_AIR_MinRSL">\n' + 
        "<value>#{@rss_BH_AIR_MinRSL}</value>\n" +
      "</Data>\n" +
        '<Data name="State">\n' + 
        "<value>#{@state}</value>\n" +
      "</Data>\n" +
        '<Data name="Connected_to_HBS">\n' + 
        "<value>#{@_connected_to_HBS}</value>\n" +
      "</Data>\n" +
        '<Data name="Timestamp">\n' + 
        "<value>#{@timestamp}</value>\n" +
      "</Data>\n" +
        '<Data name="RSSI">\n' + 
        "<value>#{@addres}</value>\n" +
      "</Data>" +
      '<Data name="Ping to Remote">\n' + 
        "<value>#{@ping_to_remote}</value>\n" +
      "</Data>" +
    "</ExtendedData>" +
        "   <Point>\n"+
         "     <coordinates>#{@lng},#{@lat}</coordinates>\n"+
         "   </Point>\n"+
        " </Placemark>\n"
     out.gsub(/\&/, '&amp;')
 rescue
    @error_message="#{$!} ";     
    puts @error_message
    puts self.inspect
 end    
   end #def
 end
  
end

 first = true
 rows=0
 
  puts @options
  puts ("parsing #{@options[:inputfile]} into #{@options[:myfilename]}")
 CSV.foreach(@options[:inputfile]) do |row|
  rows+=1
  if first 
    first = false

	if !file_is_valid(row)
	   puts ("file[#{@options[:inputfile]}] has bad header")
	   puts row
       raise "File is missing a required header. Must have columns of: name, address, lat, lng ..."
    else
      row.each_with_index do |col_name, i|
        case col_name.to_s.downcase.strip
          when 'name' 
            name = i
      	    puts ("name in col:#{i}");
      	  when 'address'
      	    address = i
             puts ("address in col:#{i}");
          when 'timestamp'
      		  timestamp = i
      		  puts ("timestamp in col:#{i}");
      	  when 'lat'
      		  lat = i
      		  puts ("lat in col:#{i}");
          when 'bh_air_minrsl'
            rss_BH_AIR_MinRSL = i  
            puts ("BH_AIR_MinRSL in col:#{i}");
      	  when 'bh_air_maxrsl'
            rss_BH_AIR_MaxRSL = i  
            puts ("BH_AIR_MaxRSL in col:#{i}");
     	  when 'lng'
      	    puts ("lng in col:#{i}");
      	    lng = i
      	  when 'client'
      		  puts ("client in col:#{i}");
      		  client = i
          when 'state'
            puts ("state in col:#{i}");
            state = i
          when 'connected_to_hbs'
            puts ("Connected_to_HBS  in col:#{i}");
            connected_to_hbs = i
         when 'ping to remote'
            puts ("ping to remote  in col:#{i}");
            ping_to_remote = i
          else
          puts ("not using #{col_name.to_s.downcase.strip } in col:#{i}") if DEBUG
        #    @@unused_rows << i
          end #case
      end #do
    end #

  else
     # if DEBUG then puts ("parsing row:#{row}"); end
     if row[1..4]== "name" then next end;
      @locations << Location.new(:name => "#{rows}@", :address => row[address], :lat => row[lat], :lng => row[lng],  :timestamp => row[timestamp], :BH_AIR_MinRSL=> row[rss_BH_AIR_MinRSL], :BH_AIR_MaxRSL=> row[rss_BH_AIR_MaxRSL], :state=> row[state], :connected_to_HBS => row[connected_to_hbs], :ping_to_remote  => row[ping_to_remote])
  #  puts @locations.last.to_kml
    
  end
  
end
 #puts @locations.each.to_kml

 if DEBUG then puts ("writing KML"); end
File.open(@options[:myfilename], @options[:writemode]) do |f|
  f.write(DOCTYPE + "\n" + "<Document>\n"+ " <name>Bynet TDT</name>\n")
 
  
  id=''
  Colors.each do |color|
    f.write("  <Style id=\"sn_shaded_dot#{id}\">\n")
    f.write("   	<IconStyle>\n")
    f.write("     		<color>FF#{color}</color>\n") #red
    f.write("     		<scale>0.5</scale>\n")
    f.write("     		<Icon>\n")
    f.write("        		<href>http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png</href>\n")
    f.write("     		</Icon>\n")
    f.write("   	</IconStyle>\n")
    f.write("     <LabelStyle>\n")
    f.write("         <scale>0.2</scale>\n")
    f.write("     </LabelStyle>\n")    
    f.write("   	<ListStyle>\n")
  	f.write("   	</ListStyle>\n")
    f.write("  </Style>\n")
	f.write("  <Style id=\"sh_shaded_dot#{id}FF\">\n")
    f.write("   	<IconStyle>\n")
    f.write("     		<color>FF#{color}</color>\n") #red
    f.write("     		<scale>0.8</scale>\n")
    f.write("     		<Icon>\n")
    f.write("        		<href>http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png</href>\n")
    f.write("     		</Icon>\n")
    f.write("   	</IconStyle>\n")    
    f.write("     <LabelStyle>\n")
    f.write("         <scale>0.4</scale>\n")
    f.write("     </LabelStyle>\n")
    f.write("   	<ListStyle>\n")
	f.write("		</ListStyle>\n")
    f.write("  </Style>\n")
    f.write("  <Style id=\"sn_forbidden#{id}\">\n")
    f.write("     <IconStyle>\n")
    f.write("         <color>FF#{color}</color>\n") #red
    f.write("         <scale>0.5</scale>\n")
    f.write("         <Icon>\n")
    f.write("           <href>http://maps.google.com/mapfiles/kml/shapes/forbidden.png</href>\n")
    f.write("         </Icon>\n")
    f.write("     </IconStyle>\n")
    f.write("     <LabelStyle>\n")
    f.write("         <scale>0.2</scale>\n")
    f.write("     </LabelStyle>\n")    
    f.write("     <ListStyle>\n")
    f.write("     </ListStyle>\n")
    f.write("  </Style>\n")
  f.write("  <Style id=\"sh_forbidden#{id}FF\">\n")
    f.write("     <IconStyle>\n")
    f.write("         <color>FF#{color}</color>\n") #red
    f.write("         <scale>0.8</scale>\n")
    f.write("         <Icon>\n")
    f.write("           <href>http://maps.google.com/mapfiles/kml/shapes/forbidden.png</href>\n")
    f.write("         </Icon>\n")
    f.write("     </IconStyle>\n")    
    f.write("     <LabelStyle>\n")
    f.write("         <scale>0.4</scale>\n")
    f.write("     </LabelStyle>\n")
    f.write("     <ListStyle>\n")
  f.write("   </ListStyle>\n")
    f.write("  </Style>\n")
    id=(id=='')? 0: id + 1;
 
    index=''

    color_i=1;
    @@labelColors.each do |color|
    f.write("<StyleMap id=\"label_color#{color_i}\">\n")
    f.write("     <LabelStyle>\n")
    f.write("         <color>#{color}</color>\n")
    f.write("     </LabelStyle>\n")
    f.write("</StyleMap>\n")
    color_i+=1
    end  
    @rss_styles.each do |rss_level|
      f.write("<StyleMap id=\"msn_shaded_dot#{index}\">\n")  
      f.write("     <Pair>\n")
      f.write("       <key>normal</key>\n")
      f.write("       <styleUrl>#sn_shaded_dot#{index}</styleUrl>\n")
      f.write("     </Pair>\n")
	  f.write("    <Pair>\n")
	  f.write("      <key>highlight</key>\n")
      f.write("      <styleUrl>#sh_shaded_dot#{index}</styleUrl>\n")
      f.write("    </Pair>\n")
	  f.write("</StyleMap>\n")
    f.write("<StyleMap id=\"msn_forbidden#{index}\">\n")  
      f.write("     <Pair>\n")
      f.write("       <key>normal</key>\n")
      f.write("       <styleUrl>#sn_forbidden#{index}</styleUrl>\n")
      f.write("     </Pair>\n")
    f.write("    <Pair>\n")
    f.write("      <key>highlight</key>\n")
      f.write("      <styleUrl>#sh_forbidden#{index}</styleUrl>\n")
      f.write("    </Pair>\n")
    f.write("</StyleMap>\n")
	  index=(id=='')? 0: index.to_i + 1;
  	end  
    
  end   
   geofactory = RGeo::Geographic.spherical_factory 
   my_lat = @locations[0].lat.gsub(/[N]/,'')
   my_lng = @locations[0].lng.gsub(/[E]/,'')
   start_loc= geofactory.point(my_lat,my_lng)
#   puts loc0
   index=0
   #TODO: ADD containers to BST
  last_HBS="" 
  num_of_locations=@locations.count
  sortedLocations = @locations.sort_by(&:connected_to_HBS)
 # puts sortedLocations.first.inspect
 # puts sortedLocations.last.inspect
 # puts sortedLocations.last.connected_to_HBS
  # puts (" verify sort #{sortedLocations.count}/#{num_of_locations}")
  sortedLocations.each do |location|
   # puts ( "1 #{location.connected_to_HBS}");
    if location.connected_to_HBS == "Connected_to_HBS " then index+=1; next end;
    if location.address.to_i > -20 then index+=1; next end;
	#if location.connected_to_HBS == "None" then index+=1; next end;
	#if location.connected_to_HBS == "1" then index+=1; next end;
	#if location.connected_to_HBS == "BH_LAN_OK" then index+=1; next end;
	if (not(DISPLAY_ZERO_RSS) && (location.address == "0")) then index+=1; next end;
    if location.connected_to_HBS == last_HBS then
      f.write("#{location.to_kml}\n")
    else
      puts ("Sorted index:#{index} new folder last was:'#{last_HBS}'' new is '#{location.connected_to_HBS}'")
      folderName = location.connected_to_HBS == "" ? 'No Base Station' : "#{location.connected_to_HBS}";
      f.write("</Folder>") unless last_HBS=="";
      last_HBS="#{location.connected_to_HBS}";
      f.write("<Folder>\n<name>#{folderName}</name>\n") 
      f.write("#{location.to_kml}\n");
    end  
    index+=1
    # myloc =  geofactory.point(location.lat,location.lng)	
    # puts ("distance to start #{index}:"+myloc.distance(loc0).to_s)
#    puts Time.now().strftime("Now is %H:%M:%S.%3N")
  end #locations
 
#<open>1</open>
#    <Camera>
#      <longitude>-122.4790</longitude>
#      <latitude>37.8110</latitude>
#      <altitude>127</altitude>
#      <heading>18.0</heading>
#      <tilt>85</tilt>
#      <altitudeMode>absolute</altitudeMode>
#    </Camera>

#<gx:Tour>
#    <name>Play me!</name>
#    <gx:Playlist>
#
#      <gx:FlyTo>
#        <gx:duration>5.0</gx:duration>
#        <!-- bounce is the default flyToMode -->
#        <Camera>
#          <longitude>170.157</longitude>
#          <latitude>-43.671</latitude>
#          <altitude>9700</altitude>
#          <heading>-6.333</heading>
#          <tilt>33.5</tilt>
#        </Camera>
#      </gx:FlyTo>
#
# <gx:AnimatedUpdate>
#        <gx:duration>0.0</gx:duration>
#        <Update>
#          <targetHref/>
#          <Change>
#            <Placemark targetId="pin2">
#              <gx:balloonVisibility>1</gx:balloonVisibility>
#            </Placemark>
#          </Change>
#        </Update>
#      </gx:AnimatedUpdate>
#
#      <gx:Wait>
#        <gx:duration>6.0</gx:duration>
#      </gx:Wait>
#
#   </gx:Playlist>
# </gx:Tour>



f.write("</Folder>\n")

f.write("<open>1</open>\n")
f.write("<gx:Tour>\n")
f.write("<name>Goto First Point</name>\n")
f.write(" <gx:Playlist>\n")
f.write("  <gx:FlyTo>\n")
f.write("   <gx:duration>5.0</gx:duration>\n")
f.write("	<Camera>\n")
f.write("	  <longitude>#{sortedLocations.first.lng}</longitude>\n")
f.write("	  <latitude>#{sortedLocations.first.lat}</latitude>\n")
f.write("	  <altitude>28000</altitude>\n")
f.write("	  <heading>0</heading>\n")
f.write("	  <tilt>0</tilt>\n")
f.write("	  <altitudeMode>absolute</altitudeMode>\n")
f.write("	</Camera>\n")
f.write("  </gx:FlyTo>\n")
f.write(" </gx:Playlist>\n")
f.write("</gx:Tour>\n")
f.write("</Document>\n</kml>")
  puts ("processed #{index} lines")
 end
