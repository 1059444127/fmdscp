IF "%1"=="Debug" (
  SET TYPE=Debug
) ELSE (
  IF "%1"=="Release" (
    SET TYPE=Release
  ) ELSE (
    SET TYPE=Debug
  )
)

SET BUILD_DIR=%CD%
SET DEVSPACE=%CD%

cd %DEVSPACE%
git clone --branch=master https://github.com/madler/zlib.git
cd zlib
git pull
mkdir build-%TYPE%
cd build-%TYPE%
cmake.exe .. -G "Visual Studio 11" -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /D NDEBUG" -DCMAKE_C_FLAGS_DEBUG="/D_DEBUG /MTd /Od" -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\zlib\%TYPE%
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj
if ERRORLEVEL 1 exit %ERRORLEVEL%
IF "%TYPE%" == "Release" copy /Y %DEVSPACE%\zlib\Release\lib\zlibstatic.lib %DEVSPACE%\zlib\Release\lib\zlib_o.lib
IF "%TYPE%" == "Debug"   copy /Y %DEVSPACE%\zlib\Debug\lib\zlibstaticd.lib %DEVSPACE%\zlib\Debug\lib\zlib_d.lib

cd %DEVSPACE%
git clone git://git.dcmtk.org/dcmtk.git
cd dcmtk
git pull
git checkout -f 5371e1d84526e7544ab7e70fb47e3cdb4e9231b2
mkdir build-%TYPE%
cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DDCMTK_WIDE_CHAR_FILE_IO_FUNCTIONS=1 -DDCMTK_WITH_ZLIB=1 -DWITH_ZLIBINC=%DEVSPACE%\zlib\%TYPE% -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\dcmtk\%TYPE%
msbuild /maxcpucount:8 /P:Configuration=%TYPE% INSTALL.vcxproj
if ERRORLEVEL 1 exit %ERRORLEVEL%

cd %DEVSPACE%
git clone --branch=openjpeg-2.1 https://github.com/uclouvain/openjpeg.git
cd openjpeg
git pull
mkdir build-%TYPE%
cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DBUILD_THIRDPARTY=1 -DBUILD_SHARED_LIBS=0 -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /D NDEBUG" -DCMAKE_C_FLAGS_DEBUG="/D_DEBUG /MTd /Od" -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\openjpeg\%TYPE%
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj
if ERRORLEVEL 1 exit %ERRORLEVEL%

cd %DEVSPACE%
git clone --branch=master https://github.com/DraconPern/fmjpeg2koj.git
cd fmjpeg2koj
git pull
mkdir build-%TYPE%
cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DBUILD_SHARED_LIBS=OFF -DBUILD_THIRDPARTY=ON -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /D NDEBUG" -DCMAKE_CXX_FLAGS_DEBUG="/D_DEBUG /MTd /Od" -DOPENJPEG=%DEVSPACE%\openjpeg\%TYPE% -DDCMTK_DIR=%DEVSPACE%\dcmtk\%TYPE% -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\fmjpeg2koj\%TYPE%
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj
if ERRORLEVEL 1 exit %ERRORLEVEL%

cd %DEVSPACE%
wget -c http://downloads.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.zip
unzip -n boost_1_60_0.zip
cd boost_1_60_0
call bootstrap
rem http://lists.boost.org/Archives/boost/2014/08/216440.php
IF "%TYPE%" == "Release" b2 toolset=msvc-11.0 asmflags=\safeseh runtime-link=static define=_BIND_TO_CURRENT_VCLIBS_VERSION=1 -j 4 --with-thread --with-filesystem --with-system --with-date_time --with-regex --with-context --with-coroutine stage release
IF "%TYPE%" == "Debug"   b2 toolset=msvc-11.0 asmflags=\safeseh runtime-link=static define=_BIND_TO_CURRENT_VCLIBS_VERSION=1 -j 4 --with-thread --with-filesystem --with-system --with-date_time --with-regex --with-context --with-coroutine stage debug

cd %DEVSPACE%
wget -C https://dev.mysql.com/get/Downloads/Connector-C/mysql-connector-c-6.1.6-src.zip
unzip -n mysql-connector-c-6.1.6-src.zip
cd mysql-connector-c-6.1.6-src
mkdir build-%TYPE%
cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /D NDEBUG" -DCMAKE_CXX_FLAGS_DEBUG="/D_DEBUG /MTd /Od /Zi" -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\mysql-connector-c-6.1.6-src\%TYPE%
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj
SET MYSQL_DIR=%DEVSPACE%\mysql-connector-c-6.1.6-src\%TYPE%

cd %DEVSPACE%
git clone https://github.com/pocoproject/poco.git --branch poco-1.6.1 --single-branch
cd %DEVSPACE%\poco
mkdir build-%TYPE%
cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DPOCO_STATIC=ON -DENABLE_NETSSL=OFF -DENABLE_CRYPTO=OFF -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /D NDEBUG" -DCMAKE_CXX_FLAGS_DEBUG="/D_DEBUG /MTd /Od /Zi" -DMYSQL_LIB=%DEVSPACE%\mysql-connector-c-6.1.6-src\%TYPE%\lib\mysqlclient -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\poco\%TYPE% 
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj
if ERRORLEVEL 1 exit %ERRORLEVEL%

REM cd %DEVSPACE%\openssl-1.0.1p
REM IF %TYPE% == "Release" "c:\Perl\bin\perl.exe" Configure -D_CRT_SECURE_NO_WARNINGS=1 no-asm --prefix=%DEVSPACE%\openssl-Release VC-WIN32 
REM IF %TYPE% == "Debug"   "c:\Perl\bin\perl.exe" Configure -D_CRT_SECURE_NO_WARNINGS=1 no-asm --prefix=%DEVSPACE%\openssl-Debug debug-VC-WIN32 
REM call ms\do_ms
REM nmake -f ms\ntdll.mak install

cd %BUILD_DIR%
git pull
git clone https://github.com/eidheim/Simple-Web-Server.git
mkdir build-%TYPE%
cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DCMAKE_BUILD_TYPE=%TYPE% -DBOOST_ROOT=%DEVSPACE%\boost_1_60_0 -DDCMTK_DIR=%DEVSPACE%\dcmtk\%TYPE% -DZLIB_ROOT=%DEVSPACE%\zlib\%TYPE% -DFMJPEG2K=%DEVSPACE%\fmjpeg2koj\%TYPE% -DOPENJPEG=%DEVSPACE%\openjpeg\%TYPE% -DPOCO=%DEVSPACE%\poco\%TYPE%
msbuild /P:Configuration=%TYPE% ALL_BUILD.vcxproj
if ERRORLEVEL 1 exit %ERRORLEVEL%

cd %BUILD_DIR%
