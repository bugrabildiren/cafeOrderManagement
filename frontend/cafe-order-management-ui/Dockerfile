# Build stage
FROM node:20 AS build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Serve stage
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/dist/cafe-order-management-ui/browser /usr/share/nginx/html/
RUN cp /usr/share/nginx/html/index.csr.html /usr/share/nginx/html/index.html
EXPOSE 80
