docker run -v volumeBici:/home/deposit/build --name onlineContainerBici -m 4GB -e TAG=1.1.0 -e PRODUCT=bici code-deposit:1.0
docker run -v volumeBici:/home/deposit/build/offline --name offlineContainerBici -m 4GB --net none --add-host=deposit:10.0.0.1 --hostname=deposit -it code-deposit:1.0 bash

docker rm onlineContainerBici offlineContainerBici
docker volume rm volumeBici