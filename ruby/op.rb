#OzPing version 0.1 date 12-7-2012
#Usage op -h <host>
# before first usage
# Install ruby
# added bundle to install
# "gem install net-ping"
# "gem install win32/security"
# "gem install logger"
#
# changes in 0.1
# adding fp_h using fp_host 
# adding fp_w adding fp_timeout

require 'rubygems'
require 'net/ping'
require 'optparse'
require 'logger'
require 'timeout'

#Default setting
VERSION=0.1
NUMBER_OF_PINGS=4
MAXTIMEOUT=200
ERRORTIMEOUT=100
DISPLAY_OUTPUT=false
DEBUG=false
LOG_INFO=true
DISPLAY_EVERY=20
DISPLAY_EVERY_ERROR=1
 
#Setting up options and parsing command line
options = {:host => ENV['fp_h']||nil , :retries => NUMBER_OF_PINGS, :timeout => (ENV['fp_w']||MAXTIMEOUT).to_i, :port => '80', 
           :mode => 'ICMP', :errorsLog => 'c:\temp\logs\op_errors_logs.txt', :errorTimeout => (ENV['fp_e']||ERRORTIMEOUT).to_i }

parser = OptionParser.new do|opts|
	opts.banner = "Usage: op [host][options]\n"
	opts.on('-h', '--host host', 'Host') do |host|
		options[:host] = host;
	end

	opts.on('-n', '--retries retries', 'Retries') do |retries|
		options[:retries] = retries.to_i;
	end

	opts.on('-c', '--continus', 'Continus Ping Setting retries to 2,147,483,647 overides -n') do |retries|
		options[:retries] = 2147483647;
	end
	
	opts.on('-w', '--wait timeout', 'Wait timeout') do |timeout|
		options[:timeout] = timeout.to_i;
	end
	
	opts.on('-e', '--ErrorWait timeout', 'Wait timeout after ERROR') do |errorTimeout|
		options[:errorTimeout] = errorTimeout.to_i;
	end
	
	opts.on('-p', '--port', 'Port port') do |port|
		options[:port] = port;
	end
	
    opts.on('-m', '--mode', 'Mode TCP/UDP/ICMP') do |my_mode|
		options[:mode] = my_mode;
		puts "setting mode to #{my_mode}"
		options[:mode] = 'TCP' if my_mode==true
	end

    opts.on('-L', '--ErrorsLog', 'Errors log <file_name_with_full_path>') do |el|
		options[:errorsLog] = el;
	end
	
	
    opts.on('--h', '--help', 'Displays Help') do
		puts opts
		exit
	end
end

parser.parse!

$LOG = Logger.new(options[:errorsLog])

if (options[:host] == nil )
    no_host = ARGV[0]==nil ||  ARGV[0][1]=='-' 
    if  no_host
		print 'Enter Host: ' 
		options[:host] = gets.chomp 
	else
	  options[:host] = ARGV[0]
	end	
	
end
timeout= options[:timeout]
start_time = Time.now;
startMessage = 'Pinging host ' + options[:host].to_s + ' with protocol '+ options[:mode].to_s+ ' max timeout:' + options[:timeout].to_s + 'ms for '+ options[:retries].to_s + ' attempts';
puts options #if DEBUG
puts startMessage 
puts "OzPing Version:#{VERSION} Please run op --help for help";
$LOG.info(startMessage)

#setting ping timeout
Net::Ping#timeout=( 5) ;

index=1 ;
success=0;
failures=0;
      
#begin #catch ctrl^c on -c
if options[:mode]=='ICMP'
 puts ("Starting ICMP MODE")
is_admin = false
begin
  
  #def is_current_user_local_admin?
  is_admin = `powershell "(@(([ADSI]'WinNT://./Administrators,group').psbase.Invoke('Members')) | foreach {$_.GetType().InvokeMember('Name', 'GetProperty', $null, $_, $null)}) -contains 'Administrator'"`.include? "True" 
  puts ("is admin=#{is_admin}" )
  
 # Win32::Registry::HKEY_USERS.open('S-1-5-19') {|reg| }
  is_admin = true

  
  
  rescue
end


last_error_time = Time.now
last_good_time = Time.now
last_ping_state=nil	  

if !is_admin
   puts "Must Run ICMP with Admin Privliage switching to TCP" 
   options[:mode]='TCP'
   options[:port]=80;
else   
 begin #setup ICMP and check admin
 do_icmp=true
 pingResponse = Net::Ping::ICMP.new(options[:host],options[:port],[[timeout/1000 , 1].max,5 ].min);
 rescue #rescue if not admin
   puts "Must Run OP in ICMP mode with Admin Privilege switching to TCP" 
   options[:mode]='TCP'
   options[:port]=80;
   do_icmp=false
   #break
 end
 puts pingResponse.inspect.force_encoding("ASCII") if DEBUG;
 
 last_ping_successful = nil
 last_message = ""
 display_once = false
 while (index <= options[:retries] && do_icmp)
    begin #rescue
	  beginning_time = Time.now
	  pr = false
	  status = Timeout::timeout(timeout/1000.0) { pr = pingResponse.ping } 
	  puts ("Status = #{status} ping Result = #{pr} ") if DEBUG
      if status && pr then
		success   +=1
	    if last_ping_successful then 
		  good_duration = Time.now - last_error_time
		  display_once = false
		else
		   # puts ("duration of good pings #{Time.now - last_error_time }") unless index==1
		   good_duration = Time.now - beginning_time ;
		   timeout= options[:timeout]
		   puts ("#{last_message} TO=>#{timeout}ms ") if DISPLAY_OUTPUT
		   display_once = true
		   
		end
		last_good_time = Time.now
		last_ping_successful = true
		end_time = Time.now
	    #puts ("[#{index}]Pinging Host #{options[:host]} Successful response in #{pingResponse.duration} execution time #{(end_time - beginning_time)*1000} milliseconds") if DISPLAY_OUTPUT
		last_message = "S#{index}S #{last_good_time.strftime('%H:%M:%S.%3N')} in #{(pingResponse.duration*1000).to_i}ms exec #{((end_time - beginning_time)*1000).to_i}ms success duration #{Time.at(good_duration).utc.strftime('%H:%M:%S.%3N')} "
		puts (last_message) if DISPLAY_OUTPUT
		if display_once then
		  puts ("#{last_message} TO=>#{timeout}ms ") if !DISPLAY_OUTPUT
		else
		   if ( !DISPLAY_OUTPUT && (index % DISPLAY_EVERY == 0))
             display_once=true		  
			 puts (last_message)
		  end 	  
		end
		$LOG.info(last_message) if LOG_INFO
	  else
	    failures +=1
		last_error_time = Time.now
		if last_ping_successful then
		  error_duration = Time.now - beginning_time
		  timeout= options[:errorTimeout]
		  puts ("#{last_message} TO=>#{timeout}ms ") unless (display_once || DISPLAY_OUTPUT)
		else
		  error_duration = Time.now - last_good_time
		end
		end_time = Time.now
		# puts ("[#{index}]Pinging Host #{options[:host]} failed response in #{pingResponse.duration} execution time #{(end_time - beginning_time)*1000} milliseconds") if DISPLAY_OUTPUT
		if pingResponse.exception
		   if pingResponse.exception.to_s=="execution expired" then
		      puts ("#{last_message} TO=>#{timeout}ms ") unless (display_once || DISPLAY_OUTPUT)
			  timeout= options[:errorTimeout]
			  display_once=true
		   else
			  do_icmp = false 
			  failures -=1
			  puts "Exception:'#{pingResponse.exception}' detected !!! Aborting ! IGNORE following ROWs"
			  index-=1
		    end
		end
		last_message = "F#{index}F #{Time.at(last_error_time).strftime('%H:%M:%S.%3N')} in #{((pingResponse.duration||0)*1000).to_i}ms exec #{((end_time - beginning_time)*1000).to_i}ms Failure duration #{Time.at(error_duration).utc.strftime('%H:%M:%S.%3N')}  TO=>#{timeout}ms"
        puts (last_message) if DISPLAY_OUTPUT
		puts (last_message) if ( !DISPLAY_OUTPUT && (index % DISPLAY_EVERY_ERROR == 0) )
		$LOG.info(last_message) if LOG_INFO
		#Time.at(elapsed_time).utc.
		last_ping_successful = false
	  end
	rescue Interrupt  
	  do_icmp = false
	rescue Exception => exc
	   end_time = Time.now
	   last_error_time = Time.now
		if last_ping_successful then
		  error_duration = Time.now - beginning_time
		  timeout= options[:errorTimeout]
		  puts ("#{last_message} TO=>#{timeout}ms ") if (DISPLAY_OUTPUT||!display_once)
		  
		else
		  error_duration = Time.now - last_good_time
		end

	   #$LOG.error("[#{index}] Ping exception  message #{exc.message}")
	   puts "[#{index}] Ping exception  message #{exc.message}" if DEBUG
	   last_message= "EE#{index}EE #{last_error_time.strftime('%H:%M:%S.%3N')} in #{((pingResponse.duration||0)*1000).to_i}ms exec #{((end_time - beginning_time)*1000).to_i}ms Failure duration #{Time.at(error_duration).utc.strftime('%H:%M:%S.%3N')} "
	   puts (last_message) if DISPLAY_OUTPUT
	   puts (last_message) if ( !DISPLAY_OUTPUT && (index % DISPLAY_EVERY_ERROR == 0) )
	   $LOG.info(last_message) if LOG_INFO
	   #puts ("EE[#{index}]EE Pinging Host #{options[:host]} Exception response in #{(end_time - beginning_time)*1000} milliseconds") if DISPLAY_OUTPUT
	   last_ping_successful = false
	   failures += 1
	ensure
	 #puts ("[#{index}]Pinging Host #{options[:host]} #{last_ping_successful ? 'Successfull' : 'Failed' } response in #{(end_time - beginning_time)*1000} milliseconds") if DISPLAY_OUTPUT
	
	 index+=1;
	 puts pingResponse.ping? if DEBUG 
	 puts pingResponse.inspect if DEBUG 
	end
  end #while
 end #is_admin?
end

display_once = false
if options[:mode]=='TCP' then
  puts ("Starting TCP MODE")
  index =1
  pingResponse = Net::Ping.new(options[:host],options[:port],[[timeout/1000 , 1].max,5 ].min);
  do_tcp=true;
  last_good_time = Time.now
  
  while (index <= options[:retries] && do_tcp )
    begin #rescue
	  last_ping_successful = nil
      beginning_time = Time.now
	  last_error_time =  Time.now
	  last_good_time = Time.now
	  begin
        pingResponse = Timeout::timeout(timeout/1000.0) {Net::Ping::TCP.new(options[:host],options[:port]||'0')} ;
	  rescue Exception => exc
	    puts("EEEEEEEEEEEEEEEEE cat ping in TCP mode Exception:#{exc.message}")
	  end
	  pr = false
	  status = Timeout::timeout(timeout/1000.0) { pr = pingResponse.ping } 
	  puts ("Status = #{status} ping Result = #{pr}") if DEBUG
	  if status && pr then
		success   +=1
		last_good_time = Time.now
		if last_ping_successful then 
		  good_duration = Time.now - last_error_time
		  display_once = false
		else
		   # puts ("duration of good pings #{Time.now - last_error_time }") unless index==1
		   good_duration = Time.now - beginning_time ;
		   puts (last_message) if DISPLAY_OUTPUT
		   display_once = false
		end
		last_ping_successful = true
		end_time = Time.now
		last_message = "S#{index}S #{Time.now.strftime('%H:%M:%S.%3N')} in #{pingResponse.duration*1000}ms exec #{(end_time - beginning_time)*1000}ms"
		puts (last_message) if DISPLAY_OUTPUT
		puts (last_message) if display_once
		puts (last_message) if ( !DISPLAY_OUTPUT && (index % DISPLAY_EVERY == 0) )
		$LOG.info(last_message) if LOG_INFO
	  else
	    failures +=1
		last_error_time = Time.now
		if last_ping_successful then
		  error_duration = Time.now - beginning_time
		  puts (last_message)
		else
		  error_duration = Time.now - last_good_time
		end
		if pingResponse.exception
		  do_tcp = false 
		  failures -=1
		  index-=1;
		  puts "Interrupt detected aborting IGNORE LAST ROW"
		end
		end_time = Time.now
		last_ping_successful = false
		last_message = "F#{index}F #{Time.now.strftime('%H:%M:%S.%3N')} in #{(pingResponse.duration||0)*1000}ms exec #{(end_time - beginning_time)*1000}ms"
		puts (last_message) if DISPLAY_OUTPUT
		$LOG.info(last_message) if LOG_INFO
		puts (last_message) if ( !DISPLAY_OUTPUT && (index % DISPLAY_EVERY == 0) )
	  end
	# rescue Exception => exc
	  rescue Exception => exc
	   failures += 1
	   if last_ping_successful then
		  error_duration = Time.now - beginning_time
		  puts (last_message) if DISPLAY_OUTPUT
		else
		  error_duration = Time.now - last_good_time
		end
	   if pingResponse.exception
		  do_tcp = false 
		  failures -=1
		  index-=1;
		   puts "Exception:#{pingResponse.exception} detected !! Aborting !! IGNORE Following ROWs"
		   
		end
	   end_time = Time.now 
	   $LOG.error("Ping exception   #{exc.message}")
	   	last_message = "EE#{index}EE #{Time.now.strftime('%H:%M:%S.%3N')} in #{(pingResponse.duration||0)*1000}ms exec #{(end_time - beginning_time)*1000}ms"
		puts (last_message) if DISPLAY_OUTPUT
		$LOG.info(last_message) if LOG_INFO
		puts (last_message) if ( !DISPLAY_OUTPUT && (index % DISPLAY_EVERY == 0) )
	   last_ping_successful = false
	   puts ("[EE#{index}EE #{Time.now.strftime('%H:%M:%S.%3N')} in #{(pingResponse.duration||0)*1000}ms exec #{(end_time - beginning_time)*1000}ms") if DISPLAY_OUTPUT
	   puts (last_message) if ( !DISPLAY_OUTPUT && (index % DISPLAY_EVERY_ERROR == 0) )
	ensure
	 index+=1;
	 #puts ("[#{index}]TCP Pinging Host #{options[:host]} #{last_ping_successful ? 'Successfull' : 'Failed' } response in #{(end_time - beginning_time)*1000} milliseconds") if DISPLAY_OUTPUT
	 puts pingResponse.ping? if DEBUG 
	 puts pingResponse.inspect if DEBUG 
	end
  end #while
end #if
#reducing index to execution numbers
# rescue SystemExit, Interrupt, StandardError => e
#rescue SystemExit, Interrupt
#ensure #rescue ctrl^c
index-=1;
success_rate = (success*100.0/ index )
failure_rate = (failures*100.0/ index )
puts (last_message)
puts ("Finished ping host #{options[:host].to_s}  Success = #{success}/#{index} [#{success_rate.to_s}] Failed = #{failures}/#{index} [#{failure_rate.to_s}] in #{(Time.now - start_time)}s")
#end #rescue ctrl^c 