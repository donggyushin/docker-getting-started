# syntax=docker/dockerfile:1

# node:12-alpine 이미지를 이용한다
FROM node:12-alpine
RUN apk add --no-cache python g++ make
WORKDIR /app

# application을 복사한다
COPY . .

# yarn 을 이용해 dependencies 를 설치한다
RUN yarn install --production

# 컨테이너가 실행되면서 기본으로 실행되는 커맨드
CMD ["node", "src/index.js"]