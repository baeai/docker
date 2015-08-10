FROM oracle/oraclelinux:6

RUN yum localinstall -y yum localinstall https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm

RUN yum install -y gcc-c++ \
patch readline readline-devel zlib zlib-devel libyaml-devel \
libffi-devel openssl-devel make bzip2 tar \
autoconf automake libtool bison iconv-devel \
java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64 \
beanstalkd-1.9-2.el6.x86_64 jemalloc jemalloc-devel

##Compiling ruby 2.1 from source
RUN curl -O https://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.6.tar.gz \
&& tar zxvf ruby-2.1.6.tar.gz

RUN cd ruby-2.1.6 && mkdir /opt/ruby \
&& ./configure --prefix=/opt/ruby \
&& make \
&& make install

RUN echo "export PATH=/opt/ruby/bin:$PATH" >>/etc/profile.d/ruby2.1.sh

ENV PATH /opt/ruby/bin:$PATH

RUN gem install fluentd --no-ri --no-rdoc \
&& fluentd --setup ./fluent

# HACK to install specific gem's while PR's are waiting to be merged
#RUN gem install specific_install \
#    && gem specific_install https://github.com/icereval/fluent-plugin-logentries.git master

ENV LD_PRELOAD /usr/lib64/libjemalloc.so

VOLUME /etc/fluent

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
