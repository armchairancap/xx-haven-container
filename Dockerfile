# 
# docker run -it --rm -p 3080:80 --name speakeasy speakeasy npm run start
# 
FROM node:16
EXPOSE 80

RUN mkdir -p /usr/src/app/speakeasy
WORKDIR  /usr/src/app/speakeasy

RUN mkdir -p /usr/src/app/speakeasy
WORKDIR  /usr/src/app/speakeasy
RUN apt-get update && apt-get install -y git
RUN git clone https://git.xx.network/elixxir/speakeasy-web /usr/src/app/speakeasy \ 
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/app/speakeasy/.next
RUN sed -i 's/next start/next start -p 80/g' package.json
RUN sed -i 's/const nextConfig = {/const nextConfig ={\n  productionBrowserSourceMaps: true,/g' next.config.js
RUN rm -rf node_modules && npm install -g npm@9.4.0 && npm install && npx next telemetry disable && npx next build

CMD ["npm start"]

