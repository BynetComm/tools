# tools
This repo is central Communication Testing Tools wrapped by fast configuration and executing scripts for Bynet employess and partners

1st you need to make sure you have ruby / rails
 
 https://s3.amazonaws.com/railsinstaller/Windows/railsinstaller-3.0.0.exe

 To complete this install you need to download or copy 
  http://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/AddTrustExternalCARoot-2048.pem
  
  to
  
  c:\temp\AddTrustExternalCARoot-2048.pem c:\RailsInstaller\Ruby2.0.0\lib\ruby\2.0.0\rubygems\ssl_certs\AddTrustExternalCARoot-2048.pem

<if you have wget http://sourceforge.net/projects/gnuwin32/files/wget/1.11.4-1/wget-1.11.4-1-setup.exe/download?use_mirror=garr >
mkdir c:\temp
cd c:\temp
wget https://s3.amazonaws.com/railsinstaller/Windows/railsinstaller-3.0.0.exe --no-check-certificate
wget http://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/AddTrustExternalCARoot-2048.pem --no-check-certificate
cmd /k railsinstaller-3.0.0.exe
move c:\temp\AddTrustExternalCARoot-2048.pem c:\RailsInstaller\Ruby2.0.0\lib\ruby\2.0.0\rubygems\ssl_certs\AddTrustExternalCARoot-2048.pem
del c:\temp\railsinstaller-3.0.0.exe  
  
  
Things you need before you get started

Git & GitHub

Check if Git is installed
In the terminal type git --version (1.8 or higher preferred)
If not, download Git [here] (http://git-scm.com/downloads). Then, setup your local Git profile - In the terminal:
Type git config --global user.name "your-name"
Type git config --global user.email "your-email"

To check if Git is already config-ed you can type git config --list
Create a free GitHub account or login if you already have one
