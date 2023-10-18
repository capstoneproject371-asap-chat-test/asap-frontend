FROM node:lts-alpine AS build
WORKDIR /asap-frontend
COPY package*.json ./
RUN npm install
RUN npm i daisyui
COPY . .
# RUN npm run build
RUN npm run generate

FROM nginx:stable-alpine as production-stage
# COPY --from=build /asap-frontend/.nuxt/dist /usr/share/nginx/html
COPY --from=build /asap-frontend/.output/public /usr/share/nginx/html
EXPOSE 80
