FROM oracle/oraclelinux:6

RUN yum localinstall -y yum localinstall https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
RUN yum localinstall -y http://packages.treasuredata.com.s3.amazonaws.com/2/redhat/6/x86_64/td-agent-2.0.0-0.el6.x86_64.rpm

RUN yum install -y gcc-c++ \
patch readline readline-devel zlib zlib-devel libyaml-devel \
libffi-devel openssl-devel make bzip2 tar \
autoconf automake libtool bison iconv-devel \
java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64 \
beanstalkd-1.9-2.el6.x86_64

##Compiling ruby 2.1 from source
RUN curl -O https://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.6.tar.gz \
&& tar zxvf ruby-2.1.6.tar.gz

RUN cd ruby-2.1.6 && mkdir /opt/ruby \
&& ./configure --prefix=/opt/ruby \
&& make \
&& make install

RUN echo "export PATH=/opt/ruby/bin:$PATH" >>/etc/profile.d/ruby2.1.sh

RUN useradd logm

RUN mkdir /var/log/log_management \
/var/log_management_queue_files \
/var/log_management_queue_binlogs \
&& chown logm:logm  /var/log/log_management \
/var/log_management_queue_files \
/var/log_management_queue_binlogs 

ENV PATH /opt/ruby/bin:$PATH

RUN gem install fluentd \
&& gem install thrift -- --with-cppflags='-D_FORTIFY_SOURCE=0' \
&& gem install beanstalk-client \
&& gem install rspec

