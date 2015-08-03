#!/bin/bash
set -e

export PATH=$PATH:/LogicalDOC-Community/bin:/usr/libexec/postfix

if [[ -z $MYSQL_SERVER ]] ; then
echo "MYSQL_SERVER not specified"
exit 1
fi


if [[ ! -e /opt/application-installed.txt ]] ; then


##running java command with here doc input

	cd /opt && java -jar logicaldoc-installer.jar <<EOF  
1
/LogicalDOC-Community
1
1
silversky
silversky
syseng@silversky.com
silversky.com
1
0
1
logicaldoc
Silversky5
$MYSQL_SERVER
3306
logicaldoc
mysqld
0
1
Silversky5
8080
8443
9005
1
3205
1
/opt/openoffice4
/usr/bin/convert
/usr/bin/gs
/usr/local/bin
/usr/local/bin/tesseract
/usr/bin/clamscan
/usr/bin/openssl
1
N
EOF
sed -i '/ulimit/d' /LogicalDOC-Community/bin/logicaldoc.sh
sed -i '27s/start/run/' /LogicalDOC-Community/bin/logicaldoc.sh
sed -i '35s/start/run/' /LogicalDOC-Community/bin/logicaldoc.sh
chmod 755 /LogicalDOC-Community/bin/log*
touch /opt/application-installed.txt
else

logicaldoc.sh start

fi

