### https://xupeiyao.github.io/2020/01/25/deploy_baget/


docker volume create --name baget
docker volume ls



docker run -d --name BaGet -p 5555:80 --env-file baget.env -v baget:/var/baget loicsharma/baget:latest


### nginx.conf

 server {
                listen          80;
                server_name     baget-repo.rpgp.cc;
                proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header   X-Forwarded-Proto $scheme;
                proxy_set_header   Host $host;

                location / {
                        proxy_pass http://127.0.0.1:5555;
                }
        }
