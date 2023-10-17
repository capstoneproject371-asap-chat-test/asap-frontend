FROM node:lts-alpine AS build
WORKDIR /asap-frontend
COPY package*.json ./
RUN npm install
RUN npm i daisyui
COPY . .
RUN npm run build

FROM nginx:stable-alpine as production-stage
COPY --from=build /asap-frontend/.nuxt/dist /usr/share/nginx/html
EXPOSE 80