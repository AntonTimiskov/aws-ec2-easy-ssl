# Easy way to get SSL certificates on AWS EC2 instance with IAM Role and stores it on AWS S3

Requires:  
**awscli** and **jq** installed

Uses AWS IAM Role temporary credentials. Discovers it automatically.  

```
./request-ssl.sh <domain> <email> <S3-URI>

Example:
./request-ssl.sh mysubdomain.example.com name@example.com s3://certificates
```


