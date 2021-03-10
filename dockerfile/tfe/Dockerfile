FROM centos:7

COPY  MESA-Framework.repo /etc/yum.repos.d/

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
  tfe

RUN yum install -y \
  epel-release \
  python3 \
  gdb \
  numactl \
  tcpdump \
  net-tools \
  vim \
  && pip3 install supervisor \ 
  && yum clean all

CMD tail -f /dev/null
  

#ENTRYPOINT ["cat","/root/test.txt"]

