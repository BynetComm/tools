require 'net/telnet'
require 'csv'
#require 'rails/all'
require 'date'
require 'snmp'

# Initialize the rails application
puts "<host> <executions> <out_file> "
#move to INI File
  VERSION = "2.01"
  pingHosts = Hash.new
  pingHosts = { :BH => '10.0.0.130' , :HBS => '10.0.0.120', :remote => '8.8.8.8'};
  hbs_IP = { :HBS_0 => '10.0.0.120',:HBS_1 => '65.15.0.185', :HBS_2 => '65.15.0.67',  :HBS_3 => '65.15.0.157', :HBS_4 => '65.15.0.47', 
          :HBS_5 => '65.15.0.40', :HBS_6 => '65.15.0.101', :HBS_7 => '65.15.0.21', :HBS_8 => '0.0.0.0' , :HBS_9 => '65.15.0.101'};
		  
  hmus_IP = { :HMU_1 => '10.0.0.130'};        
  hbs_oids_r = ""
 # hmus_oids_r = ""
  delay = "Pings off";
  gps_last = "GPS off"
  mySNMPDATA="";
  varbind_seperator=" ";
  hbs_OIDs = { 
			   :my_hbs1 => '1.3.6.1.4.1.4458.1000.3.1.7.2.1.13.1',	
			   :state => '1.3.6.1.4.1.4458.1000.3.1.7.2.1.5.1',
               :summary => '1.3.6.1.4.1.4458.1000.3.1.7.2.1.23.1'  }
  hmus_OIDs = {
                :winlink1000OduAirLinkDistance => '1.3.6.1.4.1.4458.1000.1.5.29.0',
				:winlink1000OduAirHssCurrentOpState  => '1.3.6.1.4.1.4458.1000.1.5.40.2.0',
				:winlink1000OduAirTotalTxPower => '1.3.6.1.4.1.4458.1000.1.5.50.0',
				:winlink1000HsuAirState => '1.3.6.1.4.1.4458.1000.4.1.1.0',
				:winlink1000HsuAirLinkState => '1.3.6.1.4.1.4458.1000.4.1.2.0',
				:winlink1000HsuAirRemoteCompressedMon => '1.3.6.1.4.1.4458.1000.4.1.6.0',
				:winlink1000OduAirRxPower => '1.3.6.1.4.1.4458.1000.1.5.9.1.0',
				:winlink1000OduAirSesState => '1.3.6.1.4.1.4458.1000.1.5.5.0'
			  }
  
  myhost = ARGV[1] ||pingHosts[:BH];
  last_base = ""
  last_base_key = "HBS_0"
  myfile = ARGV[2] ||'c:/temp/output2.csv';
  executions =  Integer(ARGV[0] || 10);
  pingResults = Hash.new;
  pingjResults = Hash.new;
  pingjResults_min = Hash.new;
  pingjResults_max = Hash.new;
  pingResults = { :BH => "N/A" , :HBS => "N/A", :remote => "N/A"};
  pingjResults = { :BH => "N/A" , :HBS => "N/A", :remote => "N/A"};
  pingjResults_min = { :BH => "N/A" , :HBS => "N/A", :remote => "N/A"};
  pingjResults_max = { :BH => "N/A" , :HBS => "N/A", :remote => "N/A"};
  snmp_array = { :Connected_to_HBS => "N/A" ,:hbsRSS=> "N/A", :hsuRSS=> "N/A" , :hbsEstTput=> "N/A" , :hsuEstTput => "N/A" } 
  mydebug=true;
  debuglevel = 1; #||1;
  pings=true;
  pingremote=false;
  snmp=true;
  jpings=false;
  telnet= false;
  telnet_air = false;
  telnet_lan = false;
  telnet_link = false;
  gps=true;
  PINGTIMEOUT = 250; #milliseconds
  SNMPTIMEOUT = 100; #milliseconds
  Existingfileopenmode = 'a+';
  targetIP = pingHosts[:BH];
  manager=nil;
#************************ end of Settings ****************************88
  gps1      = Hash.new; 
  gps2      = Hash.new;
  bh        = Hash.new;
  bh_air    = Hash.new;
  bh_lan    = Hash.new;
  partner   = Hash.new;
  my_state= "";  
   #bh = {:RSS => '0', :TX => '0', :RX=>'0'};
   bh = {:address => '0',
         :tx => '0',
         :client=>'0',
		     :state => '0' };
   bh_air = { 
         :No => '0',
         :OK => '0',
         :UAS => '0',
         :ES => '0',
         :SES => '0',
         :BBE => '0',
         :MinRSL => '0',
         :MaxRSL => '0',
         :RSLTD1 => '0',
         :RSLTD2 => '0',
         :MinTSL => '0',
         :MaxTSL => '0',
         :TSLTD1 => '0',
         :BBERTD1 => '0'  };
   bh_lan = { 
         :No => '0',
         :OK => '0',
         :UAS => '0',
         :ES => '0',
         :SES => '0',
         :BBE => '0',
         :RxMBytes => '0',
         :TxMBytes => '0',
         :EthTHRUnder => '0',
         :HighTrEx => '0' };


#No|OK|UAS|ES |SES|BBE |MinRSL|MaxRSL|RSLTD1|RSLTD2|MinTSL|MaxTSL|TSLTD1|BBERTD1|
#1 |1 |0  |0  |0  |0   |-67   |-67   |0     |0     |-8    |-8    |0     |0      |
#
#
#Command "display PM AIR current" finished OK.
#
#admin@10.0.1.1-> display PM LAN1 current
#
#No|OK|UAS|ES |SES|BBE |RxMBytes |TxMBytes |EthTHRUnder |HighTrEx |
#1 |1 |0  |0  |0  |0   |0        |0        |0           |0        |
#
#startup validations
 
# netsh wlan show interfaces | find "BSSID"

## ************* SNMP FUNCTIONS *****************


def fix_str(mystring)
   begin
     
     if mystring.nil? then
	   return nil
	 else
       a,b = mystring.split
       if b.nil? then
         return a
       else		 
	     out = b.gsub(/@value=/,'').gsub(/>/,'')
       end		 
     end
   rescue
        if mydebug && ( debuglevel > 1 ) then
          puts "rescue me on fix string"
          puts ("my in is #{mystring} my out is #{out}") 
          @error_message="#{$!}";     
          puts @error_message
        end 
    ensure 
     #  if (true) then puts ("is"); puts out end
      return out 
    end 
 end




  def getattrib (host,oid,community,numofelemetstoreturn)
    #mydebug ||= true
	#debuglevel ||= 5
	varbind_seperator ||= ' '
    
    begin
     out = ""
	 manager = manager||SNMP::Manager.new(:host => host, :port => 161, :community => community , :version => :SNMPv1)
     response = Timeout::timeout( SNMPTIMEOUT/1000 ) {manager.get([oid])}
     response.each_varbind do |vb|
         index=0 
       vb.inspect.split.each do |val|
           # puts ("#{index}:"+ val.to_s.gsub(/value=/,''))
          
           if index ==2 then
             out =  val.to_s.gsub(/value=@"/,'').gsub(/">/,'') unless (val==nil || val=="")
           else 
             if (index<=(numofelemetstoreturn+1) && index >1) then
                 out +=varbind_seperator+val.to_s 
             end
           end   
           index+=1
          end  # spliv vb into val  
     end #varbind vb
     manager.close
    rescue => e
		@error_message="#{$!}";
		puts ("#{index}:"+Time.now.to_s+ " line 167 get attrib Caught error:"+@error_message)
		puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
		out="Error" 
    ensure 
      #if mydebug && ( debuglevel > 3 ) then
	  #  puts "Ensure get attrib 195 host #{host} oid #{oid} out #{out}"
	  #end
	  return out
	end 
   end


def hextoip (inputstring)
  out=""
    out+=inputstring[0..1].to_i(16).to_s+"."
    out+=inputstring[2..3].to_i(16).to_s+"."
    out+=inputstring[4..5].to_i(16).to_s+"."
    out+=inputstring[6..7].to_i(16).to_s
    return out
end 

def hwVersion (host)
  getattrib(host,"1.3.6.1.4.1.4458.1000.1.1.2.0", 'public',1)
end  
#requires SNMP
def su_hbs (host)
   out="error"
  begin
    mget=Timeout::timeout( SNMPTIMEOUT/1000 ) {getattrib(host,"1.3.6.1.4.1.4458.1000.4.1.7.0",'public',10) }
    if mget.nil? || (mget == "") || (mget == "@SNMP::Null" )then
	  out="NIL"
    else	
	  out=mget.split(',',6)[5]||"N/A"
	end
	return out
  rescue => e
		@error_message="#{$!}";
		puts ("#{index}:"+Time.now.to_s+ " line 210 SNMP Caught error:"+@error_message)
		puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
		out="Error"
  ensure
    return out  
  end
end  

puts ("HW version for #{pingHosts[:HBS]} is #{hwVersion(pingHosts[:HBS])}")

## ************* END of SNMP FUNCTIONS *****************

def ping (host) 
  line_id=0;
  IO.popen("#{'C:/bynet/tools/net/Fping.exe'} #{host} -t 2ms -o -n 2 -w #{PINGTIMEOUT}") {
         |io| while (line = io.gets) do 
           # puts line
            line_id+=1;
            line_a = line.split(/\s+/)
           # puts line_a[1];
            if line_a[1]=="Minimum" then
              line_a = line.split(/\s+/)
             #  puts ("#{line_id} : #{line_a} ")
              return(line_a[11]||"-1")
            end
          end
        } #io
end

def pingj (host) 
  line_id=0;
  jitter_min=999999.0
  jitter_max=0.0
  jitter_count=0
  jitter_total=0.0
  jitter_avg = 0
  avg_delay = 0
  IO.popen("'C:/bynet/tools/net/Fping.exe'} #{host} -t 2ms -j -n 2 -w #{PINGTIMEOUT}") {
         |io| while (line = io.gets) do 
           # puts line
            line_id+=1;
           # puts line
            if line.include? "jitter=" then
              jitter_count+=1
              line_a = line.split(/\s+/)
            #  puts line_a[7]
              jitter=line_a[7].gsub(/jitter=/,'').to_f
              jitter_min = ( jitter > jitter_min)  ? jitter_min : jitter
              jitter_max = ( jitter > jitter_max)  ? jitter : jitter_max
              jitter_total += jitter
              jitter_count += 1
              jitter_avg = jitter_total / jitter_count
            end  
            line_a = line.split(/\s+/)
           # puts line_a[1];
            if line_a[1]=="Minimum" then
              line_a = line.split(/\s+/)
             #  puts ("#{line_id} : #{line_a} ")
             avg_delay = (line_a[11]||"-1")
            end #if min
          end #do
        } #io
        return { :avg_delay => "#{avg_delay}", :jitter_min => "#{jitter_min}", :jitter_max => "#{jitter_max}", :jitter_avg => "#{jitter_avg}"}
end

puts pingHosts
puts ("connect to device #{myhost}"+"  output file #{myfile}");
puts ("delay to HBS("+pingHosts[:HBS]+"): "+ping(pingHosts[:HBS])+" ms");
puts ("delay to monitored device(#{myhost}):"+ping(myhost)+" ms");
puts ("using jitter: #{jpings}")
# alon + oz fixme telnet set false from true

begin
  if telnet  then
    if (mydebug && debuglevel>4) then puts ("login to device") end
    tn = Net::Telnet::new("Host"=>pingHosts[:BH], "Timeout"=>1, "Output_log"=>"c:/temp/output_log.log", "Dump_log"=> "c:/temp/log/dump_log.log")
    if (mydebug && debuglevel>6) then 
      puts tn 
      tn.login('admin', 'netman') { |c| print c } ;
    else
      tn.login('admin', 'netman')
    end    
  end
  if ping(pingHosts[:HBS]) == "0.0" then
     Puts ("can't connected to host #{pingHosts[:HBS]} aborting");
    # exit unless mydebug;
  end; 
rescue
    puts ("can't connected to host #{pingHosts[:HBS]} aborting");
    exit unless mydebug;
   # telnet=false
end   
index =0;

  #{day,month,day,time,year,lat,long,junk]
puts ( "starting #{executions} executions, mydebug:#{mydebug.to_s} level #{debuglevel.to_s}") 
while (index < executions ) do
  estart= Time.now.to_f
  begin
	line_a = Array.new
    line_id=0
  if gps then
    if (mydebug && debuglevel>2) then puts ("#{index}: gpslabel") end
  begin
  #tn=Net::Telnet::new("Host"=>pingHosts[:BH], "Timeout"=>5, "Output_log"=>"c:/temp/output_log.log", "Dump_log"=> "c:/temp/log/dump_log.log")	
  
    IO.popen("#{'gpsbabel'} -c utf-8 -i garmin,get_posn -f usb:") {
         |io| while (line = io.gets) do 
			line_id+=1
            if line_id == 1 then      
			   line_a = line.split(/\s+/,3)
			  puts ("1-[#{line_id}]") if (mydebug && debuglevel>1)
			  if (mydebug && debuglevel>2) then
				 puts("line a count = #{line_a.count}  line_a is")
				 puts("[#{line_id}],#{line_a}")  
			 end	
    
	# gps1 = {:week_day => line_a[0]||"",
    #                :month => line_a[1||""],
    #                :day => line_a[2]||"",
    #                :time => line_a[3]||"",
    #                :year => line_a[4][0..3]||"" }
       			gps2 = {:lat => line_a[1]||"",
                    :lng => line_a[2]||"",
				}
               puts gps2 if (mydebug && debuglevel>2)				
            end #line_id==1
            if (line_id==2) && (gps2[:lat]=="") then
             line_a = line.split(/\s/,3)
             gps2 = {:lat => line_a[1]||"",
                    :lng => line_a[2][0..9]||"",
                    }
            end
          end
		  puts gps2 if (debuglevel > 2)
        } #io
		#puts gps2 if (debuglevel > 2)
    rescue
      if (mydebug && debuglevel>4) then
        puts "rescue me on GPSbabel"
		@error_message="#{$!}";
	    puts ("#{index}:"+Time.now.to_s+ " Caught error:"+@error_message)
	    puts("line a count=#{line_a.count}")
	    puts(line_a)
        puts gps1                
        puts gps2
      end
    ensure
      if gps1=={} then
        x = DateTime.now
        gps1 = {  :week_day => x.wday||"",
              :month => x.month||"",
              :day => x.day||"",
              :time => x.strftime("%H:%M:%S")||"",
              :year => x.year||"" }
        gps2 = {:lat => "", :lng => "" }                
      end  
    end #rescue gps  
    if (mydebug && debuglevel>6) then     
      puts ("#{index}: display gps")
      puts gps1;
      puts gps2;
    end 
  end if gps
  
  i=0
  level="unknown"
  
begin  
  if telnet  && telnet_link then
	if (mydebug && debuglevel>2) then puts ("#{index}: display link ; bh => #{pingHosts[:BH]}") end
	begin
	if tn==nil then	
	  tn=Net::Telnet::new("Host"=>pingHosts[:BH], "Timeout"=>1, "Output_log"=>"c:/temp/output_log.log", "Dump_log"=> "c:/temp/log/dump_log.log")
	  #tn = Net::Telnet::new("Host"=>pingHosts[:HBS], "Timeout"=>5, "Output_log"=>"c:/temp/output_log.log", "Dump_log"=> "c:/temp/log/dump_log.log")
	  if (mydebug && debuglevel>6) then 
		puts tn 
		tn.login('admin', 'netman') { |c| print c } ;
    	else
		Timeout.timeout(0.25) { tn.login('admin', 'netman') }
	  end
	end  
	rescue
	  	@error_message="#{$!}";
		if (mydebug && debuglevel>1) then puts ("#{index}:"+Time.now.to_s+ "telnet login error (retry):"+@error_message) end
		tn=Net::Telnet::new("Host"=>pingHosts[:BH], "Timeout"=>1, "Output_log"=>"c:/temp/output_log.log", "Dump_log"=> "c:/temp/log/dump_log.log")
		tn.login('admin', 'netman')
	end
	my_state="";
	bh[:state] = "";
	level='0';
	bh[:address]='0';
    Timeout.timeout(0.25) {
    tn.cmd('display link') do |output|
    i=0;
    splitedoutput = output.split unless (output==nil);
    splitedoutput.each do |sout|
      if sout=="RSS" then
        level = splitedoutput[i+1];
		bh[:address]=level;
      end
	  if sout=="State" then
		my_state = splitedoutput[i+1];
		bh[:state] = "#{my_state} " unless (my_state==nil)
	  end
      i=i+1;
    end #sout     
   end #output 
   if (mydebug && debuglevel>3) then puts ("#{index}: RSS=#{level}, State=#{my_state}") end
   }
end #if telnet
   li=0
  
   myparamid =0;
   hashkey=0;
   
   keys=bh_air.keys;
 if telnet && telnet_air then 
   if (mydebug && debuglevel>2) then puts ("#{index}: display PM AIR current") end   
    tn=tn||Net::Telnet::new("Host"=>pingHosts[:BH], "Timeout"=>1, "Output_log"=>"c:/temp/output_log.log", "Dump_log"=> "c:/temp/log/dump_log.log")
    tn.cmd('display PM AIR current') do |output|
      output.strip.split(/\s/).each do |line|
       line.strip.split('|').each do |line_param|
        level=line_param.match( /-{1}\d+/)||0;
        if ((level != 0) and (bh[:address]=='0')) then
          # puts ("#{li},#{myparamid}=#{level}")  
          myparamid +=1;
          bh [:address] = "#{level}".strip;
        end  #if RSS==0
        myparamid+=1;
        if (hashkey >=1 && hashkey <=14 && line_param!="") then
          bh_air[keys[hashkey-1]]=line_param;
          hashkey +=1;
        end
        if line_param == 'BBERTD1' then
          hashkey +=1;
        end  
        if (mydebug && debuglevel>6) then 
          puts line_param
        end
       end #line_param
      end #line
    end #telnet 'display PM AIR current' |output|

    if (mydebug && debuglevel>5) then
        puts bh
        puts bh_air
      end
  end #if telnet    
    #puts bh;
    myparamid =0;
    hashkey =0;
    li =0;
   if telnet && telnet_lan then 
    if (mydebug && debuglevel>2) then puts ("#{index}: display PM LAN1 current") end
      tn=tn||Net::Telnet::new("Host"=>pingHosts[:HBS], "Timeout"=>1, "Output_log"=>"c:/temp/output_log.log", "Dump_log"=> "c:/temp/log/dump_log.log")
      tn.cmd('display PM LAN1 current') do |output|
      keys=bh_lan.keys;
      li +=1;
        output.strip.split(/\s/).each do |line|
          line.strip.split('|').each do |line_param|
          myparamid +=1;
         # puts ("#{myparamid}==#{line_param}")
          
          if (hashkey >=1 && hashkey <=10 && line_param!="") then
            bh_lan[keys[hashkey-1]]=line_param;
            hashkey +=1;
            if (hashkey == 9) then
            bh[:TX] = "#{line_param} ".strip;
          end  
          if (hashkey == 10) then
            bh[:client] = "#{line_param} ".strip;
          end
          end
          if line_param == 'HighTrEx' then
            hashkey +=1;
          end  
          if (mydebug && debuglevel>6) then 
            puts line_param
          end
        end #line_param
      end #line  
    end #telnet 'display PM AIR current'
    if (mydebug && debuglevel>5) then
        puts bh
        puts bh_lan
      end
  end #if telnet
  rescue
     @error_message="#{$!}";
     puts ("#{index}:"+Time.now.to_s+ " Telent Caught error:"+@error_message)
    
  ensure
    if (mydebug && debuglevel>5) then
        puts bh
        puts bh_lan
    end

  end # begin telnets   
################33

 
	
	
	
   if snmp then
      
     begin
       if (mydebug && debuglevel>5) then puts ("#{index}: SNMP") end
          #snmp_array = { :Connected_to_HBS => "N/A" ,:hbsRSS=> "N/A", :hsuRSS=> "N/A" , :hbsEstTput=> "N/A"
          #       , :hsuEstTput => "N/A" } 
		   myHBS="";
		   #mySNMPDATA="";
		   #hmus_oids_r = "";
		   #hbsRSS="N/A";
		   #hsuRSS="N/A";
		   #hbsEstTput="N/A";
		   #hsuEstTput="N/A";
		   #myhbsIP="N/A";
		   #snmp_out="N/A";
           hmus_IP.each_value do |hmu|
             #snmp_out=getattrib(hmu, "1.3.6.1.4.1.4458.1000.4.1.7.0", 'public',10)
	         myHBS = su_hbs(hmu)			
			 hmus_OIDs.each do |key,value|
				  snmp_array[key]=fix_str(getattrib(hmu, value, 'public',4))||"N/A"
				end
				
			 if !myHBS.nil? then
				if myHBS=="Bynet_Mobility_Demo" then
				  last_base = "0"
				  hbs=hbs_IP[:HBS_0]
				  puts ("myHBS #{myHBS} hbs_ip #{hbs} ") if (mydebug && debuglevel>1)
				else #segev bases
				  hbs=hbs_IP["HBS_#{myHBS[8..8]}"]
				  last_base = myHBS[8..8]||"0";
				  puts ("myHBS #{myHBS} hbs_ip #{hbs} ") if (mydebug && debuglevel>1)
                end
                
				snmp_array[:Connected_to_HBS]=myHBS
				pingHosts[:HBS]=hbs 
				snmp_array[:hbsRSS]=fix_str(getattrib(hbs, "1.3.6.1.4.1.4458.1000.3.1.7.2.1.9.1", 'public',4))||"N/A"
				snmp_array[:hsuRSS]=fix_str(getattrib(hbs, "1.3.6.1.4.1.4458.1000.3.1.7.2.1.11.1", 'public',4))||"N/A"
				snmp_array[:hbsEstTput]=fix_str(getattrib(hbs, "1.3.6.1.4.1.4458.1000.3.1.7.2.1.6.1", 'public',4))||"N/A"
				snmp_array[:hsuEstTput]=fix_str(getattrib(hbs, "1.3.6.1.4.1.4458.1000.3.1.7.2.1.7.1", 'public',4))||"N/A"
				hbs_OIDs.each do |key,value|
				  snmp_array[key]=fix_str(getattrib(hbs, value, 'public',4))||"N/A"
				  if (mydebug && debuglevel>2) then puts ("#{index}: SNMP for hbs[#{hbs}] key #{key} is #{snmp_array[key]} without fixkey #{getattrib(hbs, value, 'public',4)}") 
				end
				
				
			 else #not connected to base
			  snmp_array = { :Connected_to_HBS => "N/C" ,:hbsRSS=> "N/C", :hsuRSS=> "N/C" , :hbsEstTput=> "N/C" , :hsuEstTput => "N/C" } 
		      puts ("SNMP on and not connected to HBS")
			 end			 
             #freq=getattrib(hmu, "1.3.6.1.4.1.4458.1000.1.5.16.0", 'public',10)||"N/A"
			 # myhbsIP=getattrib(hmu, "1.3.6.1.4.1.4458.1000.3.1.7.2.1.7", 'public',10)||"NA"; #fixme wrong mib
           end
           if (mydebug && debuglevel>1) then puts ("#{index}: SNMP out #{snmp_out} ") 
			 # puts ("freq=#{freq}")
			 puts  ("hbs=#{snmp_array[:Connected_to_HBS]}")
			 puts  ("hbsRSSI=#{snmp_array[:hbsRSS]}")
			 puts  ("hsuRSSI=#{snmp_array[:hsuRSS]}")
			 puts  ("hsuEstTput=#{snmp_array[:hsuEstTput]}")
			 puts  ("HbsEstTput=#{snmp_array[:hbsEstTput]}")
           end
			 #hmus_oids_r =  myHBS 
			 
                #      hbs_IP.each_value do |hbs|
     #        snmp_out=getattrib(hbs, "1.3.6.1.4.1.4458.1000.3.1.7.2.1.11.1", 'public',10)||[nil,nil]
     #        hbs_oids_r +=  snmp_out[1]||""
     #     end
       if (mydebug && debuglevel>6) then puts (hbs_oids_r); puts (hmus_oids_r) end
   	 rescue => e
		#puts "Error during processing: #{$!}"
		
		@error_message="#{$!}";
		puts ("#{index}:"+Time.now.to_s+ " line 575 SNMP Caught error:"+@error_message)
		puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
	  #puts snmp_out
     ensure
     end #begin_rescure
   end #snmp  

    if pings then
       #last_base_key = "HBS_"+last_base||"9" ;
       #pingHosts[:HBS] = hbs_IP[last_base_key]||hbs_IP[:HBS_9];
	   if  pingHosts[:HBS] == "" then puts ("EEEEEEEEEEEEEE last_base = #{last_base} key = #{last_base_key} EEEEEEEEEEEEEEE ") end
	   #puts ("EEEEEEEEEEEEEE ip = #{pingHosts[:HBS]}  EEEEEEEEEEEEE") 
	   pingResults[:HBS]= nil
       pingHosts.each_key do |key|
       begin
    	   if jpings then  
           results= Timeout::timeout( PINGTIMEOUT/1000 ) { pingj(pingHosts[key]) }
           pingResults[key] = results[:avg_delay]
           pingjResults[key] = results[:jitter_avg]
           pingjResults_min[key] = results[:jitter_min]
           pingjResults_max[key] = results[:jitter_max]
           if (mydebug && debuglevel>2) then 
              puts ("ping to key= #{key} ip is #{pingHosts[key]}")
              puts results
           end    
        else 
            pingResults[key]= Timeout::timeout( PINGTIMEOUT/1000 ) { ping(pingHosts[key]) }
             if (mydebug && debuglevel>2) then 
              puts ("ping to key= #{key} ip is #{pingHosts[key]}")
              puts results
             end  
         end
	  rescue => e
		@error_message="#{$!}";
		puts ("#{index}:"+Time.now.to_s+ " line 609 ping Caught error:"+@error_message)
		puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
		pingResults[key] = "timed out after #{PINGTIMEOUT} for key= #{key} ip is #{pingHosts[key]}"
		puts pingResults[key]
	  ensure
	     if (mydebug && debuglevel>2) then 
              puts ("ping to host [:#{key}](ip: #{(pingHosts[key])})is #{pingResults[key]} " ) 
         end
      end #begin_rescure	 
		 
       end  
       
        if (mydebug && debuglevel>3) then 
              puts "delay"
              puts pingResults 
              puts "Jitter"
              puts pingjResults
              puts pingjResults_min
              puts pingjResults_max
           end    
       
    end
   
   
   
    if (mydebug && debuglevel>5) then puts ("#{index}: CSV") end
    if index == 0 then
      CSV.open(myfile,  (File.exist?(myfile)? Existingfileopenmode : 'a+') ) do |csv|
 # fix me open file type CSV.open(myfile,  (File.exist?(myfile)? Existingfileopenmode : 'w') ) do |csv|
          
	 csv_line="name, "; 
     if gps then
	   gps1.each_key do |key|
         csv_line+="#{key}, "
       end  
       gps2.each_key do |key|
         csv_line+="#{key}, "
       end 
    end
    if telnet  && telnet_link then  
       bh.each_key do |key|
         csv_line+="#{key}, "
       end
    end	   
       if pings then
         pingHosts.each_key do |key|
           csv_line+="ping to #{key}, "
         end
       end
       
       if jpings then  
         pingHosts.each_key do |key|
           csv_line+="Avg Jitter to #{pingHosts[key]}, "
           csv_line+="Min Jitter to #{pingHosts[key]}, "
           csv_line+="Max Jitter to #{pingHosts[key]}, "
         end #Jitter ping results   
       end  
    if telnet  && telnet_air then   
       bh_air.each_key do |key|
         csv_line+="BH_AIR_#{key}, "
       end      
    end
	if telnet  && telnet_lan then
    	bh_lan.each_key do |key|
         csv_line+="BH_LAN_#{key}, "
       end      
    end   
       
	   	   
	   
       if snmp then
        snmp_array.each_key do |key|
           csv_line+="#{key}, "
         end
       end   
       csv_line+="timestamp, " 
	   csv_line+="PC_timestamp "
    

     	csv << csv_line.split(/,\s/) 
      end #open CSV
    end #if index=1
    
	CSV.open(myfile,"a+") do |csv|
      csv_line="#{index}, "
	if gps then  
      gps1.each_value do |value|
        csv_line+="#{value}, "
      end #gps1
      gps2.each_value do |value|
        csv_line+="#{value}, "
      end #gps2
	end
      if telnet  && telnet_link then
      bh.each_value do |value|
        csv_line+="#{value}, "
      end #bh
	end  
      if pings then
        pingResults.each_value do |value|
          csv_line+="#{value}, "
        end #ping results
      end
      if jpings then 
        pingjResults.each_value do |value| 
          csv_line+="#{value}, "
        end #Jitter ping results   
        pingjResults_min.each_value do |value| 
          csv_line+="#{value}, "
        end #Jitter ping results   
        pingjResults_max.each_value do |value| 
          csv_line+="#{value}, "
        end #Jitter ping results   
      end  
    if telnet  && telnet_air then
      bh_air.each_value do |value|
        csv_line+="#{value}, "
      end #bh_air
	end
	if telnet  && telnet_lan then
      bh_lan.each_value do |value|
        csv_line+="#{value}, "
      end #bh_lan
      #reformat timestamp 2013-01-14T12:50:43Z
	end  
    if gps then
     case gps1[:month]
      when 'Jan' 
        gps1[:month]='01'
      when 'Feb' 
        gps1[:month]='02'
      when 'Mar' 
        gps1[:month]='03'
      when 'Apr' 
        gps1[:month]='04'
      when 'May' 
        gps1[:month]='05'
      when 'Jun' 
        gps1[:month]='06'
      when 'Jul'
        gps1[:month]='07'
      when 'Aug' 
        gps1[:month]='08'
      when 'Sep' 
        gps1[:month]='09'
      when 'Oct' 
        gps1[:month]='10'
      when 'Nov' 
        gps1[:month]='11'
      when 'Dec' 
        gps1[:month]='12'
      end #case
    end #if gps  
      timestamp="#{gps1[:year]}-#{gps1[:month]}-#{gps1[:day]}T#{gps1[:time]}Z";
     # puts timestamp;
      
       if snmp then
         snmp_array.each_value do |value|
           csv_line+="#{value.gsub(/"/,'')}, "
         end
         #csv_line+= ",#{ last_base} , #{hbsRSS||''} , #{hsuRSS||''} , #{hbsEstTput||''} , #{hsuEstTput||''} "
		end   
      if gps then
	     csv_line += "#{timestamp}"
         csv_line += ", #{Time.now.to_s}"  #.strftime(%H:%M:%S.%3N)}

	  else
	     timestamp=""
		#"#{gps1[:year]}-#{gps1[:month]}-#{gps1[:day]}T#{gps1[:time]}Z";
	    csv_line += "#{Time.now.strftime('%Y-%m-%d')}T#{Time.now.strftime('%H:%M:%S')}Z"
		csv_line += ", #{Time.now.to_s}"  #.strftime(%H:%M:%S.%3N)}
      end 	  
	  


      csv << csv_line.split(/,\s/) 
    end #csv a+
    rescue => e
		@error_message="#{$!}";
		puts ("!!!! #{index}:"+Time.now.to_s+ " line 787 Caught error:"+@error_message)
		puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
    ensure
        host = last_base_key || "error N/C";
		delay = pingResults[:HBS]||"" if pings
		gps_last = gps2.to_s if gps
		tfinish= Time.now
	if (mydebug && debuglevel>0) then puts( "end of #{index+1}/#{executions}: time now is ["+tfinish.to_s+ "(#{(tfinish.to_f-estart)})] base: "+ host+" delay is:"+ delay  + " gps " +gps_last); end
	index +=1;
   end
  end #while
  puts su_hbs('10.0.0.130')
#exit