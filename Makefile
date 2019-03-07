PROJECT=catalogi
APP_NAME=solr
WD=/tmp
REPO_URI=https://github.com/violetina/solr-openshift.git
GIT_NAME=solr-openshift.git
TAG=${ENV}
TOKEN=`oc whoami -t`
path_to_oc=`which oc`
oc_registry=docker-registry-default.apps.do-prd-okp-m0.do.viaa.be
.ONESHELL:
SHELL = /bin/bash
.PHONY:	all
check-env:
ifndef ENV
  ENV=qas
endif
OC_PROJECT=catalogi
ifndef BRANCH
  BRANCH=master
endif
commit:
	git add .
	git commit -a
	git push
checkTools:
	if [ -x "${path_to_executable}" ]; then  echo "OC tools found here: ${path_to_executable}"; else echo please install the oc tools: https://github.com/openshiftorigin/releases/tag/v3.9.0; fi; uname && netstat | grep docker| grep -e CONNECTED  1> /dev/null || echo docker not running or not using linux
login:	check-env
	oc login do-prd-okp-m0.do.viaa.be:8443
	oc project "${OC_PROJECT}" ||  oc new-project "${OC_PROJECT}"
	#oc adm policy add-scc-to-user anyuid system:serviceaccount:${OC_PROJECT}:default --as system:admin --as-group system:admins -n ${APP_NAME}
	#oc adm policy add-scc-to-user privileged -n ${OC_PROJECT} -z default

clone:
	cd /tmp && git clone  --single-branch -b ${BRANCH} "${REPO_URI}" 
deploy:
	oc create -f solr-tmpl.yaml
clean:
	rm -rf /tmp/${GIT_NAME}
delete:
	oc delete dc/solr-${ENV}
all:	clean login commit clone deploy clean


