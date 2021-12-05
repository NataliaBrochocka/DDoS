#!/bin/bash

install_utils(){
    sudo apt -y update
    sudo apt -y install apache2 apache2-dev
}
configure_apache(){
    sudo mkdir -p /var/www/ddos
    sudo cp /vagrant/web_config/index.html /var/www/ddos/index.html
    sudo cp /vagrant/web_config/ddos.conf /etc/apache2/sites-available/ddos.conf
    sudo a2ensite ddos.conf
    sudo systemctl reload apache2
}
check_status(){
    sudo systemctl status apache2 >> /dev/null
    web_exit_code=$?
    if [ $web_exit_code -eq 0 ]; then
        echo -e "\n----------------------------------------------------------------------"
        echo -e "[INFO] Web server configured successfully"
    else
        echo -e "\n----------------------------------------------------------------------"
        echo -e "\033[0;31m[FAIL]\033[0m Web server failed with exit code: $web_exit_code"
    fi
}
main(){
    echo -e "###################### Setting up web server.. ######################"
    install_utils
    configure_apache
    check_status
}
main