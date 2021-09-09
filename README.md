## 이미지 생성
```
docker build -t getting-started .
```

-t: 생성될 이미지에 태깅. 여기서는 getting-started 이라는 tag 값을 이미지에 붙여주었다. 
나중에 컨테이너를 실행할 때 해당 태그를 참조해서 실행시킬 수 있음. 

. 는 현재 디렉토리에서 Dockerfile 을 찾으라는 의미

## 앱 컨테이너 실행

```
docker run -dp 3000:3000 getting-started
```

-d: 백그라운드에서 task 실행
-p {port}:{port}: 호스트의 port 와 컨테이너의 port 맵핑

## 오래된 컨테이너 제거
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
