ruby c:\bynet\tools\ruby\win_fetch_cacerts.rb
if not exist C:\RailsInstaller\cacert.pem copy C:\bynet\tools\cert\cacert.pem C:\RailsInstaller\cacert.pem
set SSL_CERT_FILE=C:\RailsInstaller\cacert.pem
setx SSL_CERT_FILE %SSL_CERT_FILE%
