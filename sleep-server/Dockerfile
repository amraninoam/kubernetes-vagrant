FROM node:12.18.1

WORKDIR /app

COPY . .

RUN npm install . -g

CMD [ "/bin/bash", "-c", "sleep-server 8080" ]
