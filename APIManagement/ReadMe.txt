API Management in Internal VNET mode with Application Gateway integration.

Mostly just copy paste commands from the docs, but for my own environment and some small adjustments

AppGW commands are missing listener on port 3443 which is also required for Management traffic


Certificates:
Requires PFX format with full certificate chain (leaf -> intermediate CA -> root CA)

1) Open certificate.crt
2) Convert to .cer (Base 64, 2nd option)

3) Export to .pfx (to be used in AppGW/APim)
https://stackoverflow.com/questions/6307886/how-to-create-pfx-file-from-certificate-and-private-key
winpty openssl pkcs12 -export -out api_certificate.pfx -inkey api_private.key -in api_certificate.crt

Priv key passphrase:
"kleppetest.com.pfx Password" in Work keepass