rm -rf testca;
rm -rf server;
rm -rf client;

mkdir testca;
cd testca;
mkdir certs private;
chmod 700 private;
echo 01 > serial;
touch index.txt;
cp ../openssl.txt openssl.cnf;
openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 365 -out ca_certificate.pem -outform PEM -subj /CN=MyTestCA/ -nodes;
openssl x509 -in ca_certificate.pem -out ca_certificate.cer -outform DER;


cd ..;
mkdir server;
cd server;
openssl genrsa -out private_key.pem 2048;
openssl req -new -key private_key.pem -out req.pem -outform PEM -subj /CN=xrabbit/O=server/ -nodes;
cd ../testca;
openssl ca -config openssl.cnf -in ../server/req.pem -out ../server/server_certificate.pem -notext -batch -extensions server_ca_extensions;
cd ../server;
openssl pkcs12 -export -out server_certificate.p12 -in server_certificate.pem -inkey private_key.pem -passout pass:rabbit;


cd ..;
mkdir client;
cd client;
openssl genrsa -out private_key.pem 2048;
openssl req -new -key private_key.pem -out req.pem -outform PEM -subj /CN=$(hostname)/O=client/ -nodes;
cd ../testca;
openssl ca -config openssl.cnf -in ../client/req.pem -out ../client/client_certificate.pem -notext -batch -extensions client_ca_extensions;
cd ../client;
openssl pkcs12 -export -out client_certificate.p12 -in client_certificate.pem -inkey private_key.pem -passout pass:rabbit;
cat private_key.pem client_certificate.pem>private_key_client_certificate.pem;

cd ..;
