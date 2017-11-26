#!/usr/bin/env bash
export DEPLOY_BRANCH=${DEPLOY_BRANCH:-development}

if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_REPO_SLUG" != "fossasia/kumar_server" -o  "$TRAVIS_BRANCH" != "$DEPLOY_BRANCH" ]; then
    echo "Skip production deployment for a very good reason."
    exit 0
fi

echo ">>> Removing obsolete gcoud files"
sudo rm -f /usr/bin/git-credential-gcloud.sh
sudo rm -f /usr/bin/bq
sudo rm -f /usr/bin/gsutil
sudo rm -f /usr/bin/gcloud

echo ">>> Installing new files"
curl https://sdk.cloud.google.com | bash;
source ~/.bashrc
gcloud components install kubectl

gcloud config set compute/zone us-central1-c

echo ">>> Decrypting credentials and authenticating gcloud account"
# Decrypt the credentials we added to the repo using the key we added with the Travis command line tool
openssl aes-256-cbc -K $encrypted_65ab87a3552d_key -iv $encrypted_65ab87a3552d_iv -in ./kubernetes/travis/Saga-874fa83917a8.json.enc -out Saga-874fa83917a8.json -d
gcloud auth activate-service-account --key-file Saga-874fa83917a8.json
export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/Saga-874fa83917a8.json
#saga-39285 is gcloud project id
gcloud config set project saga-39285
gcloud container clusters get-credentials kumarc

echo ">>> Building Docker image"
cd kubernetes/images

docker build --build-arg BRANCH=$DEPLOY_BRANCH --build-arg COMMIT_HASH=$TRAVIS_COMMIT --no-cache -t fossasia/kumar_server:$TRAVIS_COMMIT .
docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
docker tag fossasia/kumar_server:$TRAVIS_COMMIT fossasia/kumar_server:latest-$DEPLOY_BRANCH
echo ">>> Pushing docker image"
docker push fossasia/kumar_server

echo ">>> Updating deployment"
kubectl set image deployment/kumar-server --namespace=web kumar-server=fossasia/kumar_server:$TRAVIS_COMMIT
