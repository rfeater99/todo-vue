FROM ruby:2.5.1

RUN mkdir /app
WORKDIR /app

RUN apt-get update && apt install -y nodejs && bundle config build.nokogiri --use-system-libraries
