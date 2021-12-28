#!/bin/bash
HORAINICIAL=$(date +%T)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
WORDPRESS="https://wordpress.org/latest.zip"
USER="root"
PASSWORD=`(date +%s | sha256sum | base64 | head -c 32;)`
DATABASE="CREATE DATABASE wordpress;"
USERDATABASE="CREATE USER 'wordpress' IDENTIFIED BY 'wordpress';"
GRANTDATABASE="GRANT USAGE ON *.* TO 'wordpress' IDENTIFIED BY 'wordpress';"
GRANTALL="GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress';"
FLUSH="FLUSH PRIVILEGES;"
CREDENCIAL= echo "usuário: wordpress    senha: ${PASSWORD}    Nome do Banco: wordpress" > /root/credenciais.txt 
clear
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" 
echo -e "Adicionando o Repositórios.."
add-apt-repository universe 
add-apt-repository multiverse 
sudo rm /var/cache/debconf/config.dat 
sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock 
rm /var/lib/dpkg/updates/0001 
sudo dpkg --configure -a 
sleep 2;
sudo apt --fix-broken install -y  
sleep 2;
apt -y install lamp-server^ perl python apt-transport-https unzip 
apt update && apt upgrade -y && apt autoremove -y 
echo -e "Fazendo o download, instalação e configuração do WP.."
wget $WORDPRESS 
unzip latest.zip 
mv -v wordpress/ /var/www/html/wp 
cd /root/blog/
cp -v ./htaccess /var/www/html/wp/.htaccess 
cp -v ./wp-config.php /var/www/html/wp/ 
chmod -Rfv 755 /var/www/html/wp/ 
chown -Rfv www-data.www-data /var/www/html/wp/ 
rm -v latest.zip 
echo -e "Criando a Base de Dados do Wordpress, aguarde..."
mysql -u $USER -p$PASSWORD -e "$DATABASE" mysql 
mysql -u $USER -p$PASSWORD -e "$USERDATABASE" mysql 
mysql -u $USER -p$PASSWORD -e "$GRANTDATABASE" mysql 
mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql 
mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql 
echo -e "Editando o arquivo de configuração da Base de Dados do Wordpress, aguarde..."
sed 's/define('DB_PASSWORD', 'wordpress');/define('DB_PASSWORD', '${PASSWORD}'); /g' /var/www/html/wp/wp-config.php
sed -i '225 i ServerTokens ProductOnly' /etc/apache2/apache2.conf 
sed -i '226 i ServerSignature Off' /etc/apache2/apache2.conf 
systemctl restart apache2
echo -e "Arquivo editado com sucesso!!!, continuando com o script..."
#echo -e "Editando o arquivo de configuração do .htaccess do Wordpress, aguarde..."
#sed 's/ /g' /var/www/html/wp/.htaccess
echo -e "Arquivo editado com sucesso!!!, continuando com o script..."
echo -e "Instalação do Wordpress feito com Sucesso!!!"
HORAFINAL=`date +%T`
HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
echo "Credenciais salvas em: /root/credenciais.txt"
echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" 
exit 1