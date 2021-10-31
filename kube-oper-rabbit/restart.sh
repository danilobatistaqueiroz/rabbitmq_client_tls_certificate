#configurar para o kubectl baixar as imagens do docker, ou do registro privado

cd ~/labs/rabbitmq/kube-oper-rabbit;
kind delete cluster;./kind-with-registry.sh;
sleep 30;
echo '##################### cluster building finished #####################'
echo '##################### installing cluster operator #####################'

docker pull rabbitmqoperator/cluster-operator:1.10.0
docker tag rabbitmqoperator/cluster-operator:1.10.0 localhost:5000/rabbitmqoperator/cluster-operator:1.10.0
docker push localhost:5000/rabbitmqoperator/cluster-operator:1.10.0

docker pull quay.io/metallb/speaker:main
docker tag quay.io/metallb/speaker:main localhost:5000/quay.io/metallb/speaker:main
docker push localhost:5000/quay.io/metallb/speaker:main

docker pull quay.io/metallb/controller:main
docker tag quay.io/metallb/controller:main localhost:5000/quay.io/metallb/controller:main
docker push localhost:5000/quay.io/metallb/controller:main

docker pull rabbitmq:latest
docker tag rabbitmq:latest localhost:5000/rabbitmq:latest
docker push localhost:5000/rabbitmq:latest

docker pull rabbitmq:3.8.21-management
docker tag rabbitmq:3.8.21-management localhost:5000/rabbitmq:3.8.21-management
docker push localhost:5000/rabbitmq:3.8.21-management

kubectl apply -f cluster-operator.yml;
echo '##################### metallb step start #####################'
kubectl apply -f metallb/namespace.yaml;
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)";
kubectl apply -f metallb/metallb.yaml;
kubectl apply -f metallb/metallb-configmap.yaml;
echo '##################### metallb step end #####################'
kubectl create namespace rabbit-ns;
kubectl config set-context --current --namespace=rabbit-ns;
kubectl apply -f ./tls-ca-secret.yaml;
echo '##################### starting rabbitmq deployment #####################'
kubectl apply -f ./rabbitmq-deploy-tls.yaml;
sleep 30;
echo '##################### rabbitmq deployment finished #####################'
kubectl exec -it triple-rabbit-server-0 -- rabbitmqctl add_user "danilo" "danilo";
kubectl exec -it triple-rabbit-server-0 -- rabbitmqctl set_permissions -p "/" "danilo" ".*" ".*" ".*";
echo '##################### user danilo added #####################'
cd ~/labs/rabbitmq/kube-oper-rabbit/tls;
#rm -rf ./rabbitstore;
#rm -rf ./keystore.p12;
echo '##################### generating trusted store #####################'
#openssl pkcs12 -export -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES \
# -export -in ./tls-gen/basic/result/server_certificate.pem \
# -inkey ./tls-gen/basic/result/server_key.pem -name myalias -out ./keystore.p12;
#keytool -import -alias server1 -file ./tls-gen/basic/result/ca_certificate.pem -keystore ./rabbitstore;
cd ~/labs/rabbitmq/kube-oper-rabbit;