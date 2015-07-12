# tools
This repo is central Communication Testing Tools wrapped by fast configuration and executing scripts for Bynet employess and partners

# Questions
Any Q? call Oz +972-52-5528022

# Requirements
1st you need to make sure you have ruby / rails
 
 https://s3.amazonaws.com/railsinstaller/Windows/railsinstaller-3.0.0.exe

 To complete this install you need to download or copy 
  http://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/AddTrustExternalCARoot-2048.pem
  
  to
  
  c:\temp\AddTrustExternalCARoot-2048.pem c:\RailsInstaller\Ruby2.0.0\lib\ruby\2.0.0\rubygems\ssl_certs\AddTrustExternalCARoot-2048.pem

if you have wget http://sourceforge.net/projects/gnuwin32/files/wget/1.11.4-1/wget-1.11.4-1-setup.exe/download?use_mirror=garr otherwise download manualy and place in c:\temp  
```
mkdir c:\temp
cd c:\temp
wget https://s3.amazonaws.com/railsinstaller/Windows/railsinstaller-3.0.0.exe --no-check-certificate
wget http://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/AddTrustExternalCARoot-2048.pem --no-check-certificate
cmd /k railsinstaller-3.0.0.exe
move c:\temp\AddTrustExternalCARoot-2048.pem c:\RailsInstaller\Ruby2.0.0\lib\ruby\2.0.0\rubygems\ssl_certs\AddTrustExternalCARoot-2048.pem
del c:\temp\railsinstaller-3.0.0.exe  
mkdir c:\temp\logs
mkdir c:\bynet\
cd c:\bynet
git clone https://github.com/BynetComm/tools.git
cd tools
bundle install
fix_path.bat
```
# Verify Setup
```
ruby -v
gem -v
BynetTools
which foz
```
end of installation commands

# Initial Setups  

please make sure to run bundle install after cloning from within c:\bynet\tools to verify gems list

# Git
Things you need before you get started

Git & GitHub

Check if Git is installed
In the terminal type git --version (1.8 or higher preferred)
If not, download Git [here] (http://git-scm.com/downloads). Then, setup your local Git profile - In the terminal:
Type git config --global user.name "your-name"
Type git config --global user.email "your-email"

To check if Git is already config-ed you can type git config --list
Create a free GitHub account or login if you already have one


# Update & make changes
to get latest tools run update_tools.bat
To push your update run push.bat (1st you have to setup your SSH public key in github site https://github.com/settings/ssh contact oz for help 


# Tools in Repo

- NirCmd    Version 2.75 a generic Swiss army knife  (http://www.nirsoft.net/)
- Fping     Version 3.0  a fast ping utility (http://www.kwakkelflap.com)
- op        Version 1.0  a fast ping ruby wrapper (Bynet Internal) -first make sure to run op_install.bat 
- kml       Version 2.1 a custom .csv to .kml converter (Bynet Internal)
- mon       Version 2.2 a Test Drive GPS + RADWIN snmp/telnet + Fping Collector / Monitor => customized c:\temp\output.csv    
- foz       Version 1.2 a Fast ping wrapper (please run foz -s for initial setup and foz dump_env to write to Registry can be used to setup op regkeys)
- fix_path  Version 0.1 adds this Repo tools to your path and (assumes the tools are cloned into C:\Bynet\Tools)
 