FROM ubuntu:16.04
MAINTAINER xx-zhang <actanble@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


RUN mv /etc/apt/sources.list  /etc/apt/sources.list.bak
RUN cat > /etc/apt/sources.list << EOF
    deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
EOF
RUN apt-get -y update

ADD . /opt/HaboMalHunter
WORKDIR /opt/HaboMalHunter

# 更新shell的格式
RUN for x in $(find . -name *.sh -type f); do sed -i 's/\r//' $x ; done

RUN cd ./util/update_image && \
    /bin/bash update_image.sh

RUN /bin/bash package.sh

