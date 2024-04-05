FROM node:16.15.0-alpine as build

ENV NODE_ENV production
WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH

COPY package.json /app/package.json
COPY . /app

RUN npm install --only=prod \
    && npm install react-scripts@3.4.1 -g \
    && npm run build

FROM nginx:stable-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx
COPY --from=build /app/.env /usr/share/nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]