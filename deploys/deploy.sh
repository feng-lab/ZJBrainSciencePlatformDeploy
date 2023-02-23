#!/bin/bash

set -e

Usage (){
	echo -e "\033[32mUseage: sh deploy.sh [options] PROJECT_PATH \033[0m\n"
	cat <<-EOF
	PROJECT_PATH:
		Directory of the project.

	Options:
		-a <app_name>					Name of the application. If not define, use basename of the project_path
		-e <env>						Environment that want to be deployed: dev, production
		-D								Deploy to development
		-P								Deploy to production
		-S								Static project
		-c <docker_compose_file>	Custom docker compose file.
		-d <Dockerfile>					Custom Dockerfile
		-h 								Help
	EOF
	exit 1
}

## Analysis options

set -- `getopt a:c:d:DPSfh "$@"`

DOCKER_COMPOSE_FILE=""
DOCKERFILE=""
ENV="DEV"
PROJECT_TYPE=""


while [ -n $1 ]
do
	case $1 in 
		-a) APP_NAME=$2
			shift ;;
		-c) DOCKER_COMPOSE_FILE=$2
			shift ;;
		-d) DOCKERFILE=$2
			shift ;;
		-D) ENV="DEV";;
		-P) ENV="PRODUCTION";;
		-S) PROJECT_TYPE="STATIC";;
		-h) shift
		    Usage;;
		--) shift
			break;;
		*) echo "Unknown options: $1"
			Usage
	esac
	shift
done

PROJECT_PATH=`readlink -f $@`

if [ -z $PROJECT_PATH ]; then
	echo -e "\033[31m Error: PROJECT_PATH is requied \033[0m\n"
	Usage
fi


export APP_NAME=`basename $PROJECT_PATH`

DEPLOY_SCRIPTS_DIR=`dirname $(readlink -f "$0")`
CONFIG_DIR=${DEPLOY_SCRIPTS_DIR}/config
BUILDS_FILE=${DEPLOY_SCRIPTS_DIR}/builds/build_${PROJECT_TYPE}.sh
COMPOSE_TEMPLATES_FILE=${DEPLOY_SCRIPTS_DIR}/templates/docker-compose-${PROJECT_TYPE}.yaml


source ${CONFIG_DIR}/config.sh
source ${CONFIG_DIR}/config_${ENV}.sh
echo -e "\033[5;33m Staring deploying ... \033[0m\n"
echo "|| Project path: "$PROJECT_PATH
echo "|| Project type: "$PROJECT_TYPE
echo "|| Appication: "$APP_NAME
echo "|| Environment: "$ENV
echo -e "|| Replicas: "$REPLICAS


BuildNewDockerImage() {
	## build Application
	echo -e "\n\033[34mWaiting for build Application and tar the result ... \033[0m"
	cd ${PROJECT_PATH}
	source $BUILDS_FILE
	echo -e "\nbuild and tar ... \033[32m Done \033[0m"
	
	## build docker image
	echo -e "\n\033[34mWaiting for build docker image... \033[0m"
	export DOCKER_IMAGE="${DOCKER_USERNAME}/${APP_NAME}:${TAG}"
	echo "|| tag: "${TAG}
	
	if [ -z $DOCKERFILE]; then
		DOCKERFILE=$PROJECT_PATH/Dockerfile
	fi
	echo "|| Dockerfile: "${Dockerfile}
	
	docker build -t $DOCKER_IMAGE -f $DOCKERFILE $PROJECT_PATH
	echo -e "\nbuild docker iamge ... \033[32m Done \033[0m\n"
	
	echo -e "\n\033[34mWaiting for build docker image... \033[0m"
	docker login --username $DOCKER_USERNAME --password $DOCKER_TOKEN
	docker push ${DOCKER_IMAGE}
	echo -e "\npublish docker iamge ... \033[32m Done \033[0m\n"
}

GetDockerImageOnDev() {
	SERVICE_NAME=${DOCKER_STACK}_${APP_NAME}
	source ${CONFIG_DIR}/config_DEV.sh
	export DOCKER_IMAGE=`ssh ${USER}@${HOST} "docker service ls"|grep ${SERVICE_NAME}|awk '{print $5}'`
	source ${CONFIG_DIR}/config_${ENV}.sh
}

if [ $ENV = "PRODUCTION" ]; then
	echo -e '\n\033[32mPlease choose which docker image used to deploy the production environment\033[0m'
	PS3=$'Your choice: \033[01;32m'
	options=(
		"Development's Docker image" 
		"Build new docker image"
		"Quit"
	)
	select opt in "${options[@]}"
	do
		case $opt in 
			"Development's Docker image")
				echo -e "\n\033[33mFetching infomation of docker image running on development envrimont\033[0m"
				GetDockerImageOnDev
				break;;
			"Build new docker image")
				echo -e "\n\033[33mBuilding new docker image from directory $PROJECT_PATH\033[0m"
				BuildNewDockerImage 
				break;;
			"Quit")
				exit 1;;
		esac
	done
else
	BuildNewDockerImage 
fi


## deploy 
echo -e "\n\033[34mWaiting for deploy to host $HOST... \033[0m"
echo "Docker image: "${DOCKER_IMAGE}

if [ -z $DOCKER_COMPOSE_FILE ]; then 
	DOCKER_COMPOSE_FILE=${DEPLOY_SCRIPTS_DIR}/stack_yamls/${APP_NAME}.yaml
	envsubst < $COMPOSE_TEMPLATES_FILE > $DOCKER_COMPOSE_FILE
fi


rsync $DOCKER_COMPOSE_FILE $USER@$HOST:
ssh $USER@$HOST docker stack deploy -c ${APP_NAME}.yaml ${DOCKER_STACK}

echo -e "\nDeploy success ... \033[32m Done \033[0m\n"
