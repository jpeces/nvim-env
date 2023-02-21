FROM alpine:latest
ARG ssh_pub_key
EXPOSE 22

WORKDIR /root
COPY setup.sh .
RUN mkdir -p /root/.ssh && echo "$ssh_pub_key" > /root/.ssh/authorized_keys
RUN ./setup.sh

ENTRYPOINT ["/usr/sbin/sshd" , "-D"]
