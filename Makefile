PROJECTVER=15.06-stage
REPOHOST = localhost
REPOUSER = stage
REPOPATH = /home/stage/www-root/sipxecs/${PROJECTVER}/externals/CentOS_6/x86_64/
RPMPATH = RPMBUILD/RPMS/x86_64/*.rpm
SSH_OPTIONS = -o UserKnownHostsFile=./.known_hosts -o StrictHostKeyChecking=no
SCP_PARAMS = ${RPMPATH} ${REPOUSER}@${REPOHOST}:${REPOPATH}
CREATEREPO_PARAMS = ${REPOUSER}@${REPOHOST} createrepo ${REPOPATH}
MKDIR_PARAMS = ${REPOUSER}@${REPOHOST} mkdir -p ${REPOPATH}

LIBS = \
	sipx-cfengine \
	sipx-dart-sdk \
	sipx-mongodb \
	sipx-net-snmp \
	sipx-rubygems

build:
	for lib in ${LIBS}; do \
		make -C $${lib} rpm; \
		if [[ $$? -ne 0 ]]; then \
			exit 1; \
		fi; \
	done

docker-build:
	docker run -t --name sipx-base-libs-builder  -v `pwd`:/BUILD sipfoundrydev/sipx-docker-base-image \
	/bin/sh -c "cd /BUILD && yum update -y && make"; \
	docker rm sipx-base-libs-builder


deploy:
	@for lib in ${LIBS}; do \
		ssh ${SSH_OPTIONS} ${MKDIR_PARAMS}; \
		if [[ $$? -ne 0 ]]; then \
			exit 1; \
		fi; \
		scp ${SSH_OPTIONS} -r $${lib}/${SCP_PARAMS}; \
		if [[ $$? -ne 0 ]]; then \
			exit 1; \
		fi; \
		ssh ${SSH_OPTIONS} ${CREATEREPO_PARAMS}; \
		if [[ $$? -ne 0 ]]; then \
			exit 1; \
		fi; \
	done

install-deps:
	yum -y install \
	automake \
	bison \
	bzip2-devel \
	boost-devel \
	chrpath \
	createrepo \
	db4-devel \
	elfutils-devel \
	elfutils-libelf-devel \
	findutils \
	flex \
	gcc-c++ \
	git \
	gtest-devel \
	hiredis-devel \
	iproute \
	iptables \
	leveldb-devel \
	libacl-devel \
	libconfig-devel \
	libdnet-devel \
	libevent-devel \
	libmcrypt-devel \
	libpcap-devel \
	libselinux-devel \
	libsrtp-devel \
	libtool \
	libtool-ltdl-devel \
	lm_sensors-devel \
	m4 \
	mysql-devel \
	net-tools \
	openssl-devel \
	pcre-devel \
	perl \
	perl-devel \
	perl-TAP-Harness-Archive \
	perl-TAP-Harness-JUnit \
	perl-ExtUtils-Embed \
	poco-devel \
	postgresql-devel \
	python-devel \
	python-setuptools \
	rpm-build \
	rpm-devel \
	ruby \
	ruby-devel \
	rubygem-mocha \
	rubygem-rake \
	rubygems \
	scons \
	tar \
	tcp_wrappers-devel \
	tetex-dvips \
	texinfo-tex \
	tokyocabinet-devel \
	v8-devel \
	xmlrpc-c-devel



