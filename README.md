# Application Gateway Lab Environment

* Resource Group
    * Virtual Network
        * Subnet: web
    * NSG: web
        * Allow HTTP
        * Allow SSH
    * Virtual Machine
        * Nginx installed
        * NIC with public IP
            * NSG: web
        * Network watcher extension
        