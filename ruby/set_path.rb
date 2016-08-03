p= ENV["path"];
#p=p.gsub("C:\\Bynet\Tools\\GNU;","");
p+= ";C:\\Bynet\\Tools\\Net;" unless p.include?("C:\\bynet\\Tools\\Net;");
p+= "C:\\Bynet\\Tools;" unless p.include?("C:\\Bynet\\Tools;");
p += "C:\\Bynet\\Tools\\GNU\\bin;" unless p.include?("C:\\Bynet\\Tools\\GNU\\bin;") ;
p += "C:\\Bynet\\Tools\\CLI;" unless p.include?("C:\\Bynet\\Tools\\CLI;") ;
p += "C:\\Bynet\\Tools\\CURL\\bin;" unless p.include?("C:\\Bynet\\Tools\\CURL\\bin;") ;
p += "C:\\Bynet\\Tools\\nircmd;" unless p.include?("C:\\Bynet\\Tools\\nircmd;") ;
p += "C:\\RailsInstaller\\DevKit\\bin;" unless p.include?("C:\\RailsInstaller\\DevKit\\bin;");
size=p.size;
#p=p.gsub("C:\\Program Files",37.chr+"PF"+37.chr);
#p=p.gsub("C:\\Program files",37.chr+"PF"+37.chr);
#p=p.gsub("c:\\Program Files",37.chr+"PF"+37.chr);
#p=p.gsub("c:\\Program files",37.chr+"PF"+37.chr);
#p=p.gsub("C:\\Windows\\System32",37.chr+"WS"+37.chr);
#p=p.gsub("C:\\Windows\\system32",37.chr+"WS"+37.chr);
#p=p.gsub("C:\\ProgramData",37.chr+"PD"+37.chr);
puts size;
puts p;
if size <1024  
  cmd = "cmd /k setx path " +34.chr + "#{p}"  +34.chr  ;
else 
  cmd = "reg.exe ADD "+34.chr+"HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment"+34.chr+" /v Path /t REG_EXPAND_SZ /d "  +34.chr+"#{p}" +34.chr+ " /f" ;
end 
system(cmd);
system('setx PF "%PF%"'); 
#cmd = " cmd /k ruby -e 'puts ENV[" + 37.chr+ "path" +37.chr+ "].include?("+37.chr+"C:\\Bynet\\Tools;"+ 37.chr+ ")' "
#system(cmd);