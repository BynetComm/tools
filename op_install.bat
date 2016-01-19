remark install rails/ruby
ruby -v
IF NOT %ERRORLEVEL% EQU 0 goto install_ruby
goto install ozping
:install_ruby
@Echo ruby not found installing ruby
mkdir c:\temp
cd c:\temp
wget https://s3.amazonaws.com/railsinstaller/Windows/railsinstaller-3.0.0.exe
wget http://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/AddTrustExternalCARoot-2048.pem --no-check-certificate
cmd /k railsinstaller-3.0.0.exe
move c:\temp\AddTrustExternalCARoot-2048.pem c:\RailsInstaller\Ruby2.0.0\lib\ruby\2.0.0\rubygems\ssl_certs\AddTrustExternalCARoot-2048.pem
del c:\temp\railsinstaller-3.0.0.exe
:install_OzPing
remark setting requirements for op.rb
mkdir c:\temp\logs
gem install net-ping win32-security logger rgeo
