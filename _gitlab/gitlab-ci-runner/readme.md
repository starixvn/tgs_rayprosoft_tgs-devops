


https://gitlab.com/gitlab-org/charts/gitlab-runner/-/tree/main/
https://docs.gitlab.com/charts/charts/gitlab/gitlab-runner/
https://docs.gitlab.com/runner/install/kubernetes.html#configuring-gitlab-runner-using-the-helm-chart


kubectl create secret generic s3access \
    --from-literal=accesskey="YourAccessKey" \
    --from-literal=secretkey="YourSecretKey"

 
kubectl create secret docker-registry dockerhub --docker-server=https://index.docker.io/v1/ --docker-username=pgtgs --docker-password=SuperMan2021# -n gitlab-runner
  

helm install --namespace gitlab-runner gitlab-runner -f values.yaml gitlab/gitlab-runner




gitlab-runner register --url https://gitlab.com/ -r GR1348941Yx9sWnZxUJcofswj7yqz

sudo gitlab-runner register --url https://gitlab.com/ --registration-token GR1348941Yx9sWnZxUJcofswj7yqz

helm search repo -l gitlab/gitlab-runner



GR1348941Yx9sWnZxUJcofswj7yqz

GR1348941BNMzAxnnzpiWgvC98YUv



sudo gitlab-runner register --url https://gitlab.com/ --registration-token GR1348941Yx9sWnZxUJcofswj7yqz



# https://gitlab.com/rayprosoft/tgs-bo-api/-/settings/ci_cd

# Download the binary for your system
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Give it permission to execute
sudo chmod +x /usr/local/bin/gitlab-runner

# Create a GitLab Runner user
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and run as a service
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start



sudo gitlab-runner register --url https://gitlab.com/ --registration-token $REGISTRATION_TOKEN

