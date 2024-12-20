### generate CA key (ca.key) 
openssl genrsa -aes256 -passout file:/root/openssl-test/pass.txt -out ca.key 4096

### create self-signed CA Root Certificate (ca.crt)
openssl req -new -x509 -key ca.key -days 7300 -sha256 -extensions v3_ca -out ca.crt -passin file:/root/openssl-test/pass.txt

### check ca.crt content
openssl x509 -noout -text -in ca.crt

### generate intermediate CA key (ica.key)
openssl genrsa -aes256 -passout file:/root/openssl-test/pass.txt -out ica.key 4096

### generate intermediate CA CSR (ica.csr)
openssl req -sha256 -new -key ica.key -out ica.csr -passin file:/root/openssl-test/pass.txt

### sign intermediate CA certificate by Root CA (ica.crt)
openssl x509 -req -in ica.csr \
               -CA ca.crt -CAkey ca.key -passin file:/root/openssl-test/pass.txt \
               -CAserial ca.serial -CAcreateserial \
               -days 730 \
               -extensions intermediate_ca -extfile ica.ext \
               -out ica.crt

### check intermediate CA certificate
openssl x509 -noout -text -in ica.crt

### using openssl to verify ica.crt is valid   
openssl verify -CAfile ca.crt ica.crt

### generate endpoint(MW) key file (ihs.key)
openssl genrsa -aes256 -passout file:pass.txt -out ihs.key 4096

### generate endpoint(MW) csr file (ihs.csr)
openssl req -sha256 -new -key ihs.key -out ihs.csr -passin file:pass.txt

### sign endpoint(MW) crt (ihs.crt)
openssl x509 -req -in ihs.csr \
               -CA ica.crt -CAkey ica.key -passin file:pass.txt\
               -CAserial ica.serial -CAcreateserial \
               -days 365 \
               -out ihs.crt

### check endpoint(MW) crt (ihs.crt)
openssl x509 -noout -text -in ihs.crt

### using openssl to verify the endpoint is valid (in the key chain: CA -> ICA -> ENDPOINT)
openssl verify -CAfile ca.crt -untrusted ica.crt ihs.crt
