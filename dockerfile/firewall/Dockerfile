FROM docker.io/centos:7

COPY mrzcpd-debug-4.3.30.cee158a-1.el7.x86_64.rpm /run/
COPY mrzcpd-debug-debuginfo-4.3.30.cee158a-1.el7.x86_64.rpm /run/

COPY MESA-Framework.repo /etc/yum.repos.d/
COPY framework.conf  aws.conf /etc/ld.so.conf.d/
COPY supervisord.conf /etc/
COPY usvhost_create.sh /tmp/

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
        -i.bak /etc/yum.repos.d/CentOS-*.repo

RUN yum install libpcap numactl systemd-libs -y && \
    yum localinstall -y /run/mrzcpd-debug-4.3.30.cee158a-1.el7.x86_64.rpm && \
    yum localinstall -y /run/mrzcpd-debug-debuginfo-4.3.30.cee158a-1.el7.x86_64.rpm

RUN mkdir -p /var/run/mrzcpd/

RUN yum makecache \
  && yum install -y \
  libcjson \
  libdocumentanalyze \
  libmaatframe \
  libMESA_field_stat \
  libMESA_field_stat2 \
  libMESA_handle_logger \
  libMESA_htable\
  libMESA_prof_load \
  librdkafka \
  librulescan \
  libtsglua \
  libwiredcfg \
  libWiredLB \
  lz4 \
  libbreakpad_mini \
  sapp \
  tcpdump_mesa \
  tsg_master \
  kni \
  capture_packet_plug \
  conn_telemetry \
  dns \
  ftp \
  fw_dns_plug \
  #fw_ftp_plug \
  fw_http_plug \
  fw_mail_plug \
  fw_quic_plug \
  fw_ssl_plug \
  http \
  mail \
  quic \
  ssl \
  tsg_conn_sketch \
  app_control_plug \
  app_sketch_local \
  libwangw \
  libwire_graft 
#  http_healthcheck
  

RUN yum install -y \
  fw_ftp_plug \
  epel-release \
  python3 \
  gdb \
  numactl \
  strace \
  tcpdump \
  net-tools \
  vim \
  && pip3 install supervisor \ 
  && yum clean all \
  && ldconfig 

COPY config/sapp_run/etc/project_list.conf /home/mesasoft/sapp_run/etc/project_list.conf
COPY config/sapp_run/etc/kni/kni.conf /home/mesasoft/sapp_run/etc/kni/kni.conf
COPY config/sapp_run/etc/entrylist.conf /home/mesasoft/sapp_run/etc/entrylist.conf
COPY config/sapp_run/tsgconf/app_l7_proto_id.conf /home/mesasoft/sapp_run/tsgconf/app_l7_proto_id.conf
COPY config/sapp_run/plug/business/tsg_conn_sketch/tsg_conn_sketch.inf /home/mesasoft/sapp_run/plug/business/tsg_conn_sketch/tsg_conn_sketch.inf
COPY config/sapp_run/plug/conflist.inf /home/mesasoft/sapp_run/plug/conflist.inf

WORKDIR /home/mesasoft/sapp_run/
ENTRYPOINT ["/usr/local/bin/supervisord" ,"-n","-c", "/etc/supervisord.conf"]

