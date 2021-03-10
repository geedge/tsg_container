FROM centos:7

COPY  MESA-Framework.repo /etc/yum.repos.d/
COPY  framework.conf /etc/ld.so.conf.d/
COPY  supervisord.conf /etc/

RUN yum makecache && yum install  -y \
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
  mrzcpd \
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
  tcpdump \ 
  net-tools \
  vim  

RUN yum install -y fw_ftp_plug \
  epel-release \
  python3 \
  gdb \
  numactl \
  && pip3 install supervisor \ 
  && yum clean all \
  && ldconfig 

RUN  yum install -y strace


WORKDIR /home/mesasoft/sapp_run/
ENTRYPOINT ["/usr/local/bin/supervisord" ,"-n","-c", "/etc/supervisord.conf"]

#CMD tail -f /dev/null
