require 'net/http'

# create a path to the file "C:\RailsInstaller\"
cacert_file = File.join(%w{c: RailsInstaller cacert.pem})
cacert_file_source = File.join(%w{c: Bynet Tools Cert cacert.pem})
uri = URI('https://curl.haxx.se/ca/cacert.pem')

Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https' ) do |http|
  
  request = Net::HTTP::Get.new uri
  resp = http.request request # Net::HTTPResponse object 
  if resp.code == "200"
    open(cacert_file, "wb") { |file| file.write(resp.body) }
    puts "\n\nA bundle of certificate authorities has been installed to"
    puts "C:\\RailsInstaller\\cacert.pem\n"
    puts "* Please set SSL_CERT_FILE in your current command prompt session with:"
    puts "     set SSL_CERT_FILE=C:\\RailsInstaller\\cacert.pem"
    puts "* To make this a permanent setting, add it to Environment Variables"
    puts "  under Control Panel -> Advanced -> Environment Variables"
  else
    puts "error code: #{resp.code}"
	puts resp.body
	puts "copying from tools"
	require 'fileutils'
	FileUtils.cp(cacert_file_source, cacert_file)
    abort "\n\n>>>> A cacert.pem bundle could not be downloaded."
  end
end
