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
	done

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



