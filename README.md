# 이미지 생성
```
docker build -t getting-started .
```

-t: 생성될 이미지에 태깅. 여기서는 getting-started 이라는 tag 값을 이미지에 붙여주었다. 
나중에 컨테이너를 실행할 때 해당 태그를 참조해서 실행시킬 수 있음.

. 는 현재 디렉토리에서 Dockerfile 을 찾으라는 의미

# 앱 컨테이너 실행

```
docker run -dp 3000:3000 getting-started
```

-d: 백그라운드에서 task 실행

-p {port}:{port}: 호스트의 port 와 컨테이너의 port 맵핑

# 오래된 컨테이너 제거
```
docker ps
```
container의 id를 구하고,
```
docker stop <the-container-id>
```
해당 container의 실행을 중지 시키고,
```
docker rm <the-container-id>
```
해당 컨테이너를 삭제한다. 

# 데이터 유지하기
호스트 머신에 볼륨을 생성하고 이를 컨테이너의 데이터가 저장되는 위치에 붙이면 데이터를 유지시킬 수 있다. (이를 '마운팅'한다고 한다.)

## named volume
도커는 하드디스크에 physical location(볼륨)을 유지하고, 이를 사용하기 위해서는 해당 볼륨의 이름만 기억하면 된다. 

```
docker volume create todo-db
```
todo-db 라는 이름의 볼륨 생성

```
docker run -dp 3000:3000 -v todo-db:/etc/todos getting-started
```
-v 플래그를 붙여서 todo-db 볼륨을 컨테이너의 /etc/todos 패스에 마운팅시킨다. 

### named volume의 위치
```
docker volume inspect todo-db
```
MountPoint는 실제 하드디스크 내부에 위치해 있고, 대부분 루트권한 유저만 접근 가능하다.

### bind mounts
named volume은 도커가 하드디스크에 임의로 위치를 저장시켜놓고 이름을 이용해서 참조하며 사용하는 볼륨이라면 bind mounts는 유저가 직접 경로를 설정해주는 볼륨이다. 
https://docs.docker.com/get-started/06_bind_mounts/

# 네트워킹
기본적으로 컨테이너들은 독립적으로 동작하기 때문에 다른 컨테이너들과 상호교류를 할 수 없다. 컨테이너들끼리 상호 교류를 할 수 있게 해주는 방법은
서로 같은 네트워크 위에 올려놓으면 된다. 

## MySQL 시작하기

1. 네트워크를 생성한다. 
```
docker network create todo-app
```
2. MySQL 컨테이너를 실행시키고 네트워크에 붙인다. 
```
docker run -d \
     --network todo-app --network-alias mysql \
     -v todo-mysql-data:/var/lib/mysql \
     -e MYSQL_ROOT_PASSWORD=secret \
     -e MYSQL_DATABASE=todos \
     mysql:5.7
```
### Tip
이전에 todo-mysql-data 볼륨을 생성하지 않았는데 todo-mysql-data 라는 volume과 컨테이너의 /var/lib/mysql 패스에 마운팅시키는 것을 알 수 있다. 
이런 경우에는 도커가 알아서 자동으로 todo-mysql-data 볼륨을 생성해주기 때문에 걱정할 것 없다.

-e: 환경 변수

--network-alias: 해당 컨테이너 host의 이름. 나중에 해당 컨테이너를 참조할 때 사용. (동일 네트워크 선상에 있을때에만 참조가 가능)

3. 데이터베이스가 제대로 실행되어졌는지 확인하기 위해 데이터베이스에 직접 연결해보자.
```
docker exec -it <mysql-container-id> mysql -u root -p
```
password 프롬프트가 나오면 'secret' 을 입력한다. 

## MySQL 에 연결하기
데이터베이스가 정상적으로 동작하는 것을 확인했다면 해당 데이터베이스와 연동해보자. 

todo app은 다음의 환경변수들이 존재한다면 MySQL 에 연동되게끔 제작되어져 있다. 
```
MYSQL_HOST - the hostname for the running MySQL server
MYSQL_USER - the username to use for the connection
MYSQL_PASSWORD - the password to use for the connection
MYSQL_DB - the database to use once connected
```

위의 환경변수들을 지정해주면서 컨테이너를 동작시켜주자. 
```
docker run -dp 3000:3000 \
   -w /app -v "$(pwd):/app" \
   --network todo-app \
   -e MYSQL_HOST=mysql \
   -e MYSQL_USER=root \
   -e MYSQL_PASSWORD=secret \
   -e MYSQL_DB=todos \
   node:12-alpine \
   sh -c "yarn install && yarn run dev"
```
-w: 커맨드가 실행 될 working directory를 설정해준다. 

-v: 여기서는 named volume이 아닌 bind mounts 를 사용해주어서 현재 경로의 모든 파일을 working directory에 복사해주고 있다. 

데이터베이스에 직접 들어가서 데이터 조회해보는 방법
```
docker exec -it <mysql-container-id> mysql -p todos
```

```
mysql> select * from todo_items;
```

# Docker Compose 사용하기 

## 실행하기
Compose를 활용하여 위의 일련의 과정들을 하나의 파일화 시켜서 번거로운 작업을 없애주자. 
```
docker-compose up -d
```

로그 보기
```
docker-compose logs -f
```
## 종료하기
```
docker-compose down
```
볼륨도 함께 삭제하고 싶다면
```
docker-compose down --volume
```

## 이름없는 볼륨 삭제 

[Docker remove all dangling volumes (Example)](https://coderwall.com/p/hdsfpq/docker-remove-all-dangling-volumes)
