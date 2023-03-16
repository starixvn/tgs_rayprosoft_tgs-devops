### install
helm repo add gatus https://avakarev.github.io/gatus-chart
helm repo update

helm template gatus-devops gatus/gatus --set-file config=devops-config.yaml --set ingress.enabled=true --set ingress.hosts[0]=dev-gatus.rpgp.cc -f values.yaml -n dev

helm install gatus-devops gatus/gatus --set-file config=devops-config.yaml --set ingress.enabled=true --set ingress.hosts[0]=dev-gatus.rpgp.cc -f values.yaml -n dev

helm template gatus-game gatus/gatus --set-file config=game-config.yaml --set ingress.enabled=true --set ingress.hosts[0]=dev-gatus-game.rpgp.cc -f values.yaml -n dev

helm install gatus-game gatus/gatus --set-file config=game-config.yaml --set ingress.enabled=true --set ingress.hosts[0]=dev-gatus-game.rpgp.cc -f values.yaml -n dev
