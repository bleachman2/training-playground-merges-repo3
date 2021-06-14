FROM alpine:3.8
MAINTAINER nb24871@novabase.pt

RUN apk -U add git
RUN git config --global user.email bleachman@live.com.pt && git config --global user.name Nelson
