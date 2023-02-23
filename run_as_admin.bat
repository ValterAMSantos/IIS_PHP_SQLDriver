@echo off
set status=Successfully
CLS
@echo Make sure the script is running as Admin!
@echo.
pause
CLS
@echo.
@echo After Setting up IIS make sure the CGI Role Feature is enable!
@echo.
pause
CLS
@echo.
@echo.
@echo If PHP isn't installed yet please 
@echo download .ZIP file of PHP build from 
@echo http://windows.php.net/downloads/ 
@echo extract to desired installation folder, default is c:\php\
@echo.
pause
CLS
:SLCTDIR
@echo Select PHP directory (without trailing \) or type default or leave it blank for default c:\PHP value
set phppath=c:\php
set /P phppath=Directory:
@echo.
IF "%phppath%"=="default" (
	set phppath=c:\php
)
IF "%phppath%"=="" (
	set phppath=c:\php
)
IF exist %phppath% ( 
	@echo.
	@echo %phppath% exists and is valid!
	@echo.
) ELSE ( 
	@echo.
	@echo Invalid directory!
	goto :SLCTDIR 
)
CLS
@echo Clearing current PHP handlers
%windir%\system32\inetsrv\appcmd clear config /section:system.webServer/fastCGI
@echo.
@echo The following command will generate an error message if PHP is not installed. 
@echo This can be ignored.
%windir%\system32\inetsrv\appcmd set config /section:system.webServer/handlers /-[name='PHP_via_FastCGI']
@echo.
@echo Setting up the PHP handler
%windir%\system32\inetsrv\appcmd set config /section:system.webServer/fastCGI /+[fullPath='%phppath%\php-cgi.exe']
%windir%\system32\inetsrv\appcmd set config /section:system.webServer/handlers /+[name='PHP_via_FastCGI',path='*.php',verb='*',modules='FastCgiModule',scriptProcessor='%phppath%\php-cgi.exe',resourceType='Unspecified']
%windir%\system32\inetsrv\appcmd set config /section:system.webServer/handlers /accessPolicy:Read,Script
@echo.
@echo Configuring FastCGI Variables
%windir%\system32\inetsrv\appcmd set config -section:system.webServer/fastCgi /[fullPath='%phppath%\php-cgi.exe'].instanceMaxRequests:10000
%windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /+"[fullPath='%phppath%\php-cgi.exe'].environmentVariables.[name='PHP_FCGI_MAX_REQUESTS',value='10000']"
%windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /+"[fullPath='%phppath%\php-cgi.exe'].environmentVariables.[name='PHPRC',value='%phppath%\php.ini']"
@echo.
@echo.
@echo Creating phptestfile.php on default iis wwwroot directory
@echo.
@echo ^<?php phpinfo(); ?^> > C:\inetpub\wwwroot\phptestfile.php
@echo.
@echo Please open the following link and check if PHP was correctly installed! 
@echo http://localhost/phptestfile.php 
@echo.
@echo File will be deleted after!
@echo.
pause
CLS
@echo.
@echo Deleting PHP test file
del /f "C:\inetpub\wwwroot\phptestfile.php"
@echo.
@echo.
@echo If no errors appeared, download SQL Server Drivers for PHP from 
@echo https://docs.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server
@echo Extract the drivers to C:\tmpphp\ This directory will be deleted later!
@echo.
pause
@echo.
:CHOICEINSTALL
CLS
@echo Do you want to install the driver using the script?
@echo A new extension line will be added to the php.ini-production file!
@echo.
@echo.
@echo Y - Yes
@echo N - NO
@echo.
set /P drvopt=Select Option:
@echo.
IF "%drvopt%"=="Y" (
	CLS
	:DRVFILE
	@echo Select one of the following Drivers file to install:
	@echo.
	@echo - info:
	@echo - File is named following the next conditions:
	@echo.
	@echo The SQLSRV driver provides a procedural interface for interacting with SQL Server. 
	@echo The PDO_SQLSRV driver implements PHP's object-oriented PDO interface for working with databases.
	@echo.
	@echo Paramters:
	@echo php_sqlsrv_$1_$2_$3.dll or php_pdo_sqlsrv_$1_$2_$3.dll
	@echo.
	@echo - PHP version installed ($1)
	@echo - Threadedness ($2)
	@echo   		(TS = thread-safe)
	@echo - System architecture ($3)
	@echo.
	@echo.
	@echo Example: php_sqlsrv_80_nts_x64.dll php_pdo_sqlsrv_80_nts_x64.dll
	@echo.
	cd c:\tmpphp
	@echo.
	SET /P installoption=Select a file: 
	IF exist %installoption% ( 
		@echo.
		@echo %installoption% exists and is valid!
		@echo.
		move /Y c:\tmpphp\%installoption% %phppath%\ext\ 
		cd %phppath%
		@echo File moved to extension folder
		@echo.
		@echo Deleting c:\tmpphp folder
	    rmdir "c:\tmpphp" /s /q
		@echo Folder Deleted
		pause
		IF exist %phppath%\php.ini ( 
			CLS
			@echo.
			@echo %phppath%\php.ini exists and is valid!
			@echo.			
			@echo Setting up PHP.ini
			@echo [sqlsrv]>>%phppath%\php.ini
			@echo ;EXTENSION FOR MS SQLDRV>>%phppath%\php.ini
			@echo Extension=%installoption%>>%phppath%\php.ini
			@echo File Modified
			@echo Please restart IIS !
			pause
			CLS
			goto :EOF
		)

		CLS
		@echo Setting up PHP.ini
		@echo [sqlsrv]>>%phppath%\php.ini-production
		@echo ;EXTENSION FOR MS SQLDRV>>%phppath%\php.ini-production
		@echo Extension=%installoption%>>%phppath%\php.ini-production
		@echo Production File Modified
		copy %phppath%\php.ini-production %phppath%\php.ini
		@echo PHP.ini created and valid
		@echo Please restart IIS !
		pause
		CLS		
		goto :EOF
	) 
	@echo.
	@echo Invalid File %installoption%!
	@echo.
	pause
	goto :DRVFILE 

)
IF "%drvopt%"=="N" (
	@echo.
	@echo.
	@echo.
	@echo Please follow the Driver install instructions on the following link
	@echo  https://docs.microsoft.com/en-us/iis/application-frameworks/install-and-configure-php-on-iis/install-the-sql-server-driver-for-php
	goto :EOF
)
goto :CHOICEINSTALL
:EOF
@echo.
@echo.
@echo Script completed %status% !
pause
