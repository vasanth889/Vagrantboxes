# Vagrantboxes for Windows and MySQL5.7 
Procedure to build Windows vagrant provisioned VM. 

vagrant file and provisioner scripts which includes all the steps to build a Windows vm in your local machine.

Following tools/components will be installed.

    1.Java
    2.Git
    3.Maven
    4.Python3.6
    5.pip3.6
    6.virtualenv
    7.nodejs
    8.npm
    
## How to build the Vagrant box

### Prerequisites

Install [Oracle VM VirtualBox](http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html),Vagrant and create project directory.

### Vagrant box build process

1.Checkout this repository into your local machine using the Git clone command.

2.Download JDK exe file[[JDK 8u144-linux-x64.tar](https://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase8-2177648.html)] and add it into below folder.
```
  winmysql/files/
```
3.Download MySQL Connector[[MySQL Connector/J](https://dev.mysql.com/downloads/connector/j/)] and add it into below folder.
```
  winmysql/files/
```
4.Modify config.yaml and vagrantfile with appropriate name of JDK file.

5.Modify product value in config.yaml according to the required product which going to be tested.
(Accepted product values are apim,sp,is and ei)

6.Run the Vagrantfile with below command.
```
  vagrant up
```






