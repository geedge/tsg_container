FROM docker.io/centos:7

COPY MESA-Framework.repo /etc/yum.repos.d/
COPY framework.conf /etc/ld.so.conf.d/

RUN yum makecache && yum install -y \
  mrzcpd \
  numactl \
  zlib \
  librdkafka \
  systemd \
  libcjson \
  libmaatframe \
  libMESA_field_stat2 \
  libMESA_handle_logger \
  libMESA_htable \
  libMESA_prof_load \
  librulescan \
  libwiredcfg \
  libWiredLB \
  sapp \
  libbreakpad_mini \
  libmnl \
  libnfnetlink \
  iptables \
  iproute \
  && ldconfig

RUN yum install -y \
  epel-release \
  gdb \
  strace \
  htop \
  tcpdump \
  net-tools \
  curl \
  vim \
  python3 \
  && pip3 install supervisor \
  && yum clean all

COPY tfe-env.sh /opt/tsg/tfe/
COPY tfe-4.3.30.202103111806030800.ce55dbd-1.el7.x86_64.rpm /root/
RUN rpm -ivh /root/tfe-4.3.30.202103111806030800.ce55dbd-1.el7.x86_64.rpm && chmod o+x /opt/tsg/tfe/tfe-env.sh
COPY supervisord.conf /etc/supervisord/

WORKDIR /opt/tsg/tfe/

ENTRYPOINT ["/usr/local/bin/supervisord", "-n", "-c", "/etc/supervisord/supervisord.conf"]

# docker run -it --cap-add=NET_ADMIN --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --device /dev/net/tun:/dev/net/tun tfe:v1 /bin/bash
# supervisorctl -c /etc/supervisord/supervisord.conf status