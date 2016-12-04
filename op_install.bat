@echo off
@mkdir c:\temp >>nul
@cd c:\temp
if "%1"=="pem" goto install_pem
rem install rails/ruby
ruby -v
IF NOT %ERRORLEVEL% EQU 0 goto install_ruby
@echo found ruby installing Oz Ping
goto install_ozping
:install_ruby
@Echo ruby not found installing ruby
set old_path=%path%
path=%path%;c:\bynet\tools;c:\bynet\tools\gnu\bin;c:\bynet\tools\net
which rails
IF NOT %ERRORLEVEL% EQU 0 goto install_rails
@echo found rails updating ca certificate
goto install_ozping
:install_rails
wget https://s3.amazonaws.com/railsinstaller/Windows/railsinstaller-3.0.0.exe --no-check-certificate
railsinstaller-3.0.0.exe
rem #was# cmd /k railsinstaller-3.0.0.exe
del c:\temp\railsinstaller-3.0.0.exe
:install_pem
@Echo installing CA .pem
wget https://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/AddTrustExternalCARoot-2048.pem --no-check-certificate
move c:\temp\AddTrustExternalCARoot-2048.pem c:\RailsInstaller\Ruby2.0.0\lib\ruby\2.0.0\rubygems\ssl_certs\AddTrustExternalCARoot-2048.pem
set path=%old_path%
:install_OzPing
rem setting requirements for op.rb
<<<<<<< HEAD
@echo Setting requirements for op.rb
mkdir c:\temp\logs >>nul
mkdir c:\temp\log >>nul
gem install net-ping win32-security logger snmp rego
=======
mkdir c:\temp\logs
gem install net-ping win32-security logger rgeo snmp
rem setting requirements for op.rb
@echo Setting requirements for op.rb
mkdir c:\temp\logs >>nul
mkdir c:\temp\log >>nul

>>>>>>> 8d128d001a0f8a165fd2384bd601799ea4f028f6
