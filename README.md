# containerizando

![Capa](cover.png "Capa")

## introdução

Docker é um conjunto de produtos de plataforma como serviço que usam virtualização de nível de sistema operacional para entregar software em pacotes chamados contêineres. Os contêineres são isolados uns dos outros e agrupam seus próprios softwares, bibliotecas e arquivos de configuração

## projeto containerizando

1. gerar pacote containerizando no ![start spring](https://start.spring.io/) com as dependencias

* jpa
* postgres
* web
* actuator

2. fazer o download do zip 

3. unzip pacote

```bash
unzip containerizando.zip
```

4. configurar application.properties para o postgres

5. configurar pom para actuator

## Docker compose 

Ferramenta para definir e executar multiplos containers de forma declarativa, utilizando arquivos no formato yaml

6. executar compose para subir o banco de dados

```bash
docker-compose up -d
```

7. build:

```bash
./mvnw package
```

O build foi feito com sucesso? Retornou algum erro de conexão com o banco de dados?

8. executando a app

```bash
mvn spring-boot:run
```

O start foi feito com sucesso? Retornou algum erro de conexão com o banco de dados?

Acesso em 

http://localhost:8080/actuator/health

9. criar dockerfile para app

10. build

```bash
docker image build -t rmnobarra/containerizando:latest .
```

11. executando o container:

```bash
docker container run -p 8080:8080 -d rmnobarra/containerizando --name containerizando
```

Verificar o status do serviço em http://localhost:8080/actuator/health

Por quê a conexão com o banco não está mais funcionando?

O contexto de conexão agora mudou, durante o desenvolvimento, o build / start da aplicação conectava no localhost da estação
que executava a ação, agora, dentro do container, o localhost não tem nenhum banco de dados aguardando conexão, logo é necessário
alterar a string de conexão, permitindo que o container da aplicação fale com o container do banco de dados

13. Alterar a string de conexão no application.properties, tornando-a flexivel tanto em desenvolvimento quanto em execução, utilizando
variáveis de ambiente

14. Adicionar o containerizando no docker compose "docker-compose2.yaml"

15. validar o compose com

docker-compose config

16. iniciar o container do containerizando

Por quê a conexão com o banco de dados ainda não funciona?

Não basta somente alterar a string de conexão, é necessário buildar a aplicação novamente, assim como gerar uma nova imagem docker.
Porque o build da imagem reflete o seu estado naquele momento, cada alteração na aplicação, demanda um novo build de imagem

```bash
./mvnw package
```

```bash
docker image build -t rmnobarra/containerizando:latest .
```

docker-compose up -d containerizando

É possível iniciar ou derrubar determinado container dentro de um docker-compose utilizando o service name. Útil quando se tem diversos
serviços rodando no mesmo compose

E por quê funcionou agora?

Quando falamos de comunicação entre containers, basicamente temos 2 redes para conexão, a host network, que seria a rede aonde o serviço 
docker está sendo executado e temos a container network, que é uma rede dedicada para comunicação entre containers. É possivel
criar N redes para organizar a comunicação, quando nenhuma rede é criada, por padrão os containers são conectados a rede "_default"

Em cada container network o docker cria um serviço dns para facilitar a comunicação entre os containers, e com isso é possível a 
conexão entre containers utilizando o service name, veja a string de conexão da aplicação com o comando:

docker exec -ti containerizando_containerizando_1 env

Nenhum dado adicional além do service name do postgres foi utilizado e o actuator mostra que a conectividade entre aplicação e banco de dados
está ok.

http://localhost:8080/actuator/health

E como essa comunicação ocorre?

Basicamente temos 2 tipos de redes, a container network e host network. Quando falamos de conectividade entre containers,
a comunicação é feita diretamente via a container network.

Quando queremos acessar externamente determinado serviço que está sendo executado em um container, utilizamos a host network e um mapeamento
de portas (parâmetro -p)

Esse mapeamento nada mais é do que regras de firewall utilizando o módulo do kernel linux, netfilter

O netfilter é um módulo que fornece ao sistema operacional Linux as funções de firewall, NAT e log dos dados que trafegam por rede de computadores. Geralmente manipulamos as regras de firewall utilizando iptables ou nftables que são basicamente a interface amigável
para a gerencia das regras

Alguns comandos para listar as regras de firewall:

```bash
sudo iptables -S
```

```bash
sudo iptables -t nat -L
```

Veja o ip nas regras para o banco de dados (porta 5432) e para a aplicação (8080), redireciona automáticamente para os respectivos containers, veja seus ips:

Aplicação:
```bash
docker inspect containerizando_containerizando_1 -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

Banco de dados:
```bash
docker inspect containerizando_postgres_1 -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

## analizando a imagem utilizando o dive

O dive é uma ferramenta para explorar uma imagem docker, conteúdo de camada e descobrir maneiras de reduzir o tamanho de sua imagem Docker / OCI. (open container iniciative)

[documentação oficial](https://github.com/wagoodman/dive)

Executando:

17. pull da imagem

```bash
docker pull wagoodman/dive
```

18. Modo interativo: 

```bash
docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    wagoodman/dive:latest rmnobarra/containerizando:latest
```

Passando o parâmetro --ci, não é retornado a ui interativa, lowestEfficiency=0.8 faz o teste falhar caso a eficiência da imagem
fique abaixo de 80% e o espaço desperdiçado for maior que 45%

19. Modo ci:

```bash
docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    wagoodman/dive:latest --ci rmnobarra/containerizando:latest \
    --lowestEfficiency=0.8 --highestUserWastedPercent=0.45
```

O objetivo dessa ferramenta é tornar as imagens Docker ou OCI mais eficientes, alguns aspectos para ter em mente durante a construção:


[link](https://docs.docker.com/storage/storagedriver/)

* Copy-on-write

Copy-on-write é uma estratégia de compartilhamento e cópia de arquivos para máxima eficiência. Se um arquivo ou diretório existir em uma camada inferior da imagem e outra camada (incluindo a camada gravável) precisar de acesso de leitura a ele, ele apenas usará o arquivo existente. Na primeira vez que outra camada precisa modificar o arquivo (ao construir a imagem ou ao executar o contêiner), o arquivo é copiado para essa camada e modificado. Isso minimiza a E / S e o tamanho de cada uma das camadas subsequentes.

Este Dockerfile é um ótimo exemplo de como não criar uma imagem:

```Dockerfile
# Start with Ubuntu Trusty
FROM  phusion/baseimage:0.10.0

# Use baseimage-docker's init system.
CMD   ["/sbin/my_init"]

RUN	apt-get update
RUN apt-get -y install wget
RUN apt-get -y install curl
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get -y install nodejs git-core
RUN npm install pm2 -g --no-optional
RUN npm install yarn@1.9.4 -g

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy source files to container
COPY	. /var/www/node

# Change owner to non-root node user and set up permissions
RUN chmod -R 777 var/www/node /var/log/
RUN useradd -m node && mkdir /var/log/nodejs && chown -R node:node /var/www/node /var/log/

# Install all my packages and build
RUN	cd /var/www/node && /sbin/setuser node yarn install && /sbin/setuser node yarn build:tsoa

# Open local port 3000
EXPOSE	3030

# Run PM2 as a daemon managed by runit
RUN mkdir /etc/service/pm2 && chmod -R 777 /etc/service/pm2
ADD ./scripts/pm2.sh /etc/service/pm2/run
RUN chmod -R 777 /etc/service/pm2
```

* Multi-stage build: método de organizar um Dockerfile para minimizar o tamanho do contêiner final, melhorar o desempenho do tempo de execução, permitir uma melhor organização de comandos e arquivos do Docker e fornecer um método padronizado de execução de ações de compilação

Dockerfile após ajustes:

```Dockerfile
# Start with Ubuntu Trusty
FROM  phusion/baseimage:0.10.0 AS BuildImage

# Use baseimage-docker's init system.
CMD   ["/sbin/my_init"]

RUN	apt-get update && apt-get install -y \
    wget \
    curl \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash \
    && apt-get install -y \
    nodejs \
    git-core \
    && npm install yarn@1.9.4 -g

# Clean up APT when done.
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy source files to container
COPY	. /var/www/node

# Install all my packages and build
RUN	cd /var/www/node \
    && yarn install \
    && yarn build:tsoa \
    && yarn cache clean

FROM  phusion/baseimage:0.10.0 as RunImage

# Use baseimage-docker's init system.
CMD   ["/sbin/my_init"]

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash \
    && apt-get update && apt-get install -y nodejs \
    && npm install pm2 -g --no-optional

COPY --from=BuildImage /var/www/node /var/www/node

# Clean up APT when done.
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Change owner to non-root node user and set up permissions
RUN chmod -R 777 var/www/node /var/log/ \
    && useradd -m node \
    && mkdir /var/log/nodejs \
    && chown -R node:node /var/www/node /var/log/

# Open local port 3000
EXPOSE	3030

# Run PM2 as a daemon managed by runit
RUN mkdir /etc/service/pm2 \
    && chmod -R 777 /etc/service/pm2
ADD ./scripts/pm2.sh /etc/service/pm2/run
RUN chmod -R 777 /etc/service/pm2
```

## docker push

Com uma imagem eficiente e executando a aplicação corretamente, o próximo passo lógico e disponibiliza-la para execução além da estação
de trabalho na qual ela foi gerada, para isso hospedamos essa imagem no que chamamos de container registry.

Existe N containers registries na internet, privados ou públicos. Um dos mais populares é o docker hub.


20. docker login:

```bash
docker login
```

Este processo armazena as crendeciais dentro do .docker no home do usuario que executou o comando.

21. docker push
```bash
docker push rmnobarra/containerizando
```

Agora a imagem com a aplicação está disponivel para qualquer um que tenha acesso a internet.


### finalizando

Para saber mais:

[Docker para desenvolvedores](https://leanpub.com/dockerparadesenvolvedores)

[Canal no telegram sobre docker](https://t.me/dockerbr)

[Volumes](https://docs.docker.com/storage/)

[Open container iniciative](https://www.padok.fr/en/blog/container-docker-oci)

[Open container iniciative 2](https://www.docker.com/blog/demystifying-open-container-initiative-oci-specifications/)

[Spring boot actuator](https://www.onlinetutorialspoint.com/spring-boot/spring-boot-actuator-database-health-check.html)

[Copy on write](https://docs.docker.com/storage/storagedriver/)

[Multi Stage build](https://docs.docker.com/develop/develop-images/multistage-build/)

[Melhores praticas para Dockerfile](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)