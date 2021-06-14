FROM alpine:3.8
MAINTAINER TODO EMAIL_HERE

RUN apk -U add git
RUN git config --global user.email "TODO EMAIL_HERE" && git config --global user.name "TODO USERNAME_HERE"
