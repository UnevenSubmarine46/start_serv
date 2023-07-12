#!/bin/bash

# Решение битых ссылок версии 8.3.20.1613
# Удаляем старые ссылки

link1=/etc/init.d/srv1cv83
link2=/etc/default/srv1cv83

if [ -L $link1 ] && [ -L $link2  ];
then echo True
rm /etc/init.d/srv1cv83;
rm /etc/default/srv1cv83;
echo "Files: /etc/init.d/srv1cv83 and /etc/default/srv1cv83 DELETED!"
else
echo False
fi
# Добавляем новые ссылки
#ln -s /opt/1cv8/x86_64/8.3.20.1613/srv1cv83 /etc/init.d/srv1cv83
#ln -s /opt/1cv8/x86_64/8.3.20.1613/srv1cv83.conf /etc/default/srv1cv83
#echo "Links srv1cv83 updates!"

#Проверяем файл srv1cv83
#echo -e '\e[31m Check file srv1cv83:\e[0m'

#Проверяем, существует ли в файле строка с монтированием бэкапов
if grep -q /scripts/mount_backup.sh "/etc/init.d/srv1cv83"; then
        #Строка с монтированием бэкапов существует в файле srv1cv83
        echo 'Backup Exist!'
else
        #Дописываем строку с монтированием бэкапов в файл srv1cv83
        sed -i '/function start() {/a /scripts/mount_backup.sh' /etc/init.d/srv1cv83
                echo -e '\e[32m Mount backup writed!:\e[0m'
fi

#Проверяем, существует ли в файле строка с убийством хаспов
if grep -q 'killall usbhasp' "/etc/init.d/srv1cv83"; then
        #Строка с монтированием бэкапов существует в файле srv1cv83
        echo 'KillHasp Exist!'
else
        #Дописываем строку с убийством хаспов в файл srv1cv83
        sed -i '/mount_backup.sh/a killall usbhasp' /etc/init.d/srv1cv83
                echo -e '\e[32m Killall usbhasp writed!:\e[0m'
fi

#Проверяем, существует ли в файле строка с копированием ключей хаспов
if grep -q '/opt/HASP/usbhasp -d /opt/HASP/key/server.json /opt/HASP/key/user.json' "/etc/init.d/srv1cv83"; then
        #Строка с монтированием бэкапов существует в файле srv1cv83
        echo 'Usbhasp, server.json and user.json Exist!'
else
        #Дописываем строку с копированием ключей
        sed -i '/killall usbhasp/a /opt/HASP/usbhasp -d /opt/HASP/key/server.json /opt/HASP/key/user.json' /etc/init.d/srv1cv83
                echo -e '\e[32m Usbhasp, server.json. user.json writed!:\e[0m'
fi

#Проверяем, существует ли в файле строка с рестартом хаспов
if grep -q 'service haspd restart' "/etc/init.d/srv1cv83"; then
        #Строка с рестартом хаспов существует в файле srv1cv83
        echo 'Restart Haspd Exist!'
else
        #Дописываем строку с рестартом хаспов в файл srv1cv83
        sed -i '/user.json/a service haspd restart' /etc/init.d/srv1cv83
                echo -e '\e[32m Haspd restart writed!:\e[0m'
fi

#Проверяем, существует ли в файле строка с рестартом Apache2
if grep -q 'service apache2 restart' "/etc/init.d/srv1cv83"; then
        #Строка с рестартом Apache2 существует в файле srv1cv83
        echo 'Restart Apache2 Exist!'
else
        #Дописываем строку с рестартом Apache2 в файл srv1cv83
        sed -i '/service haspd restart/a service apache2 restart' /etc/init.d/srv1cv83
                echo -e '\e[32m Apache2 restart writed!:\e[0m'
fi
echo -e '\e[31m Check file srv1cv83 DONE\e[0m'

#Перезаписываем srv1cv83
#systemctl daemon-reload
# Обновляем srv1cv83
#echo -e '\e[31m Start update-rc.d srv1cv83 defaults\e[0m'
#update-rc.d srv1cv83 defaults
#echo -e '\e[31m Done update-rc.d srv1cv83 defaults\e[0m'

set -e
#
process=0
#
if ! [ -d "/var/log/openvpn" ];
        then mkdir /var/log/openvpn;
fi
#
if [[ `ps aux | grep -v "grep" | grep "1C" | wc -l` -gt 0 ]];
        then echo "service 1c is running! stopping service 1c...";
        systemctl stop srv1cv83;
fi
#
if [[ `ps aux | grep -v "grep" | grep -i "postgresql" | wc -l` -gt 0 ]];
        then echo "service postgresql is running! stopping service postgresql...";
        systemctl stop postgresql;
        if [[ `df -h | grep "mapper/opt" | wc -l` -gt 0 ]];
            then echo "folder /opt - mount in "`df -h | awk '/mapper\/opt/{print $1}'`;
            echo "starting service postgresql...";
            systemctl start postgresql;
            else echo "folder /opt - not mount";
            echo "mounting disk...";
            cryptsetup luksOpen /dev/sda8 opt;
            mount /dev/mapper/opt /opt;
            echo "starting service postgresql...";
            systemctl start postgresql;
        fi
        else echo "service postgresql is not running"
        echo "folder /opt - not mount, mounting disk...";
        cryptsetup luksOpen /dev/sda8 opt;
        mount /dev/mapper/opt /opt;
        echo "starting service postgresql...";
        systemctl start postgresql;
fi
#
if [ -d "/home/usr1cv8" ];
        then echo "folder /home/usr1cv8 is found";
        if [[ `df -h | grep "mapper/usr1cv8" | wc -l` -gt 0 ]];
            then echo "folder /home/usr1cv8 - mount in "`df -h | awk '/mapper\/usr1cv8/{print $1}'`;
            echo "starting service 1C...";
            if [ -L $link1 ] && [ -L $link2  ];
            then
            continue
            else
            ln -s /opt/1cv8/x86_64/8.3.20.1613/srv1cv83 /etc/init.d/srv1cv83;
            ln -s /opt/1cv8/x86_64/8.3.20.1613/srv1cv83.conf /etc/default/srv1cv83;
            update-rc.d srv1cv83 defaults;
            systemctl daemon-reload;
            fi
            systemctl start srv1cv83
            else echo "folder /home/usr1cv8 - not nount, mounting disk...";
            cryptsetup luksOpen /dev/sda7 usr1cv8;
            mount /dev/mapper/usr1cv8 /home/usr1cv8;
            echo "starting service 1C...";
            if [ -L $link1 ] && [ -L $link2  ];
            then
            continue
            else
            ln -s /opt/1cv8/x86_64/8.3.20.1613/srv1cv83 /etc/init.d/srv1cv83;
            ln -s /opt/1cv8/x86_64/8.3.20.1613/srv1cv83.conf /etc/default/srv1cv83;
            update-rc.d srv1cv83 defaults;
            systemctl daemon-reload;
            fi
            systemctl start srv1cv83;

            #echo "deleting all files from /home/usr1cv8_old";
            #rm -Rf /home/usr1cv8_old/*;
            #rm -Rf /home/usr1cv8_old/.*;
            #echo "copy all files from /home/usr1cv8 to /home/usr1cv8_old";
            #rsync -vuar /home/usr1cv8/ /home/usr1cv8_old/;
        fi
        else echo "folder /home/usr1cv8 is not found, creating folder /home/usr1cv8...";
        mkdir /home/usr1cv8;
        echo "mounting disk...";
        cryptsetup luksOpen /dev/sda7 usr1cv8
        mount /dev/mapper/usr1cv8 /home/usr1cv8
        echo "starting service 1c...";
        if [ -L $link1 ] && [ -L $link2  ];
        then
        continue
        else
        ln -s /opt/1cv8/x86_64/8.3.20.1613/srv1cv83 /etc/init.d/srv1cv83;
        ln -s /opt/1cv8/x86_64/8.3.20.1613/srv1cv83.conf /etc/default/srv1cv83;
        update-rc.d srv1cv83 defaults;
        systemctl daemon-reload;
        fi
        systemctl start srv1cv83;
fi

#
if [[ `ps aux | grep -v "grep" | grep -i "nginx" | wc -l` -gt 0 ]];
        then echo "service nginx is running";
        else echo "service nginx is not running!";
fi

#
if [[ `ps aux | grep -v "grep" | grep -i "apache" | wc -l` -gt 0 ]];
        then echo "service apache is runnning";
        else echo "service apache is not running!";
fi

SRV1CV8_VERSION=8.3.20.1613
G_VER_ARCH=x86_64
G_VER_MAJOR=`echo $SRV1CV8_VERSION | awk -F. '{print $1}'`
G_VER_MINOR=`echo $SRV1CV8_VERSION | awk -F. '{print $2}'`
G_VER_BUILD=`echo $SRV1CV8_VERSION | awk -F. '{print $3}'`
G_VER_RELEASE=`echo $SRV1CV8_VERSION | awk -F. '{print $4}'`
G_BINDIR="/opt/1cv8/${G_VER_ARCH}/${G_VER_MAJOR}.${G_VER_MINOR}.${G_VER_BUILD}.${G_VER_RELEASE}"


#
if [[ `ps aux | grep -v "grep" | grep "/ras" | wc -l` -gt 0 ]];
        then echo "service ras is running!";
        else echo "service ras is not running! starting service ras...";
        sudo -u usr1cv8 $G_BINDIR/ras --daemon cluster;
fi

#
#echo "start mount nfs share script..."
##/scripts/automount_agent.sh
#
#

killall usbhasp
/opt/HASP/usbhasp -d /opt/HASP/key/server.json /opt/HASP/key/user.json
service haspd restart
#service srv1cv83 restart
