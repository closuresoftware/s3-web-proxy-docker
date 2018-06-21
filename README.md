# s3-web-proxy
Docker image for [s3-web-proxy](https://github.com/closuresoftware/s3-web-proxy): A web server that uses Amazon S3 as backend, optimized to be used as a private maven repository.

# Supported tags and respective `Dockerfile` links

-	[`0.2.1`, `0.2`, `latest` Dockerfile](https://github.com/closuresoftware/s3-web-proxy-docker/blob/master/Dockerfile)

## What is s3-web-proxy

[s3-web-proxy](https://github.com/closuresoftware/s3-web-proxy) is a web proxy for an S3 backend, allowing GET/POST/PUT operations over the content.

It's mainly intended as a front-end for an S3 backed maven private repository, and thus authentication
is currently mandatory. Though that will be softened in the next version to allow public
GET operations.

The authentication system is limited currently to standard HTTP basic authentication,
 so you should use SSL on Tomcat, or hide it behind an SSL enabled web server such as 
 an Apache server using mod_jk.
 
The server uses a local cache to minimize the traffic to S3.

## How to use this image

This image is based on the official Tomcat 8.0 image [tomcat:8.0](https://hub.docker.com/_/tomcat/), so you can apply configurations such as CATALINA_OPTIONS.

As this is a proxy for an S3 backend, you need to set your AWS credentials and the target AWS S3 bucket in
order for it to work.

A minimal run configuration would be:

    docker run -e AWS_ACCESS_KEY_ID=my-aws-access-key \
        -e AWS_SECRET_KEY=my-aws-secret-key \
        -e AWS_REGION=default-aws-region \
        -e S3PROXY_AWS_BUCKET=my-bucket-name \
        closuresoftware/s3-web-proxy

This would start an s3-web-proxy with the built-in providers and auth file. 
The admin user name is "admin" and the password also "admin", you should change that.
And it uses a local file for storing passwords, initially empty.

Needless to say, your IAM user for the access key must have rw permissions on the bucket.

The default settings will use a maximum of 1Gb for the local cache.

## Available configuration options:

### s3proxy configuration options

* **aws.bucket** or env var **S3PROXY_AWS_BUCKET**

    this is a mandatory value, with the name of the AWS S3 bucket holding the files.
    
* **auth.provider** or env var **S3PROXY_AUTH_PROVIDER**

    This is the full class name for the UserAuthProvider to use for authenticating users.
    By default uses the built-in DefaultUserAuthProvider.
    Check the authentication section for details.

* **auth.realm** or env var **S3PROXY_AUTH_REALM**

    This is the HTTP basic authentication realm display name, by default S3 Proxy.
    
* **cache.dir** or env var **S3PROXY_CACHE_DIR**

    By default this points to /var/lib/s3proxy/cache, which is defined as a
    VOLUME in the official docker image. You should probably change this
    if you'll be running the app inside a windows machine.
    
* **cache.maxSize** or env var **S3PROXY_CACHE_MAX_SIZE**

    This is the max size of the local cache, by default 1Gb. The max size can be expressed
    as a byte value, or using a valid suffix (m for Mb or g for Gb). Default value is, accordingly,
    1g.
    
### Default auth provider options

* **auth.file** or env var **S3PROXY_AUTH_FILE**

    this is a mandatory value when using the default auth provider, contains a valid URL to load an authentication
    file. Check the authentication section for details.
    
* **auth.admin.username** or env var **S3PROXY_ADMIN_USERNAME**

    username of the admin user, by default "admin". You should change this value.

* **auth.admin.password** or env var **S3PROXY_ADMIN_PASSWORD**

    password of the admin user, by default "admin". You MUST change this value.

### Tomcat options

The image configures CATALINA_OPTIONS to set the memory requirements for the image:

    ENV CATALINA_OPTS "-XX:MaxPermSize=128m -Xms384m -Xmx384m"

So the total memory use would be around 512m.

You can override that configuration on your command line or compose file.

### AWS SDK configuration options

You must also set these environment variables in order for the AWS sdk to work (check AWS Java SDK documentation for details):

* **AWS_ACCESS_KEY_ID**

* **AWS_SECRET_KEY**

* **AWS_REGION**

## Authentication

The built-in authentication provider uses environment variables to define the admin user name and password,
and also a password file similar to htpasswd or unix passwd, with a single line per user entry.

Each entry has the form:

    username:password-digest

Where password-digest is a secure hash (MD5) of the password coded in Base64 format.

The auth.file / S3PROXY_AUTH_FILE configuration option
must be a valid URL as supported by java.net.URL, such as file: or http: or https:.

It also supports an S3 url which has the following form:

    s3://bucket-name/file-key
    
If you use file or s3 urls for the auth file, the default provider can update them and so
you can use the built-in, very simple, user management interface at

    http://myserver.address:8080/__user
    
You can't have files under the __user scope, it's reserved. 

## Considerations

s3proxy validates cache entries always against the bucket, to make sure content is always
up to date. This means that a call is always made to S3. However, files are only transferred
from S3 when the file is not available locally or the file has been updated at S3.

In future versions this might change.

The cache is an LRU system, so when the cache is over the maximum size specified entries will
be deleted choosing those which were accessed least recently.

## Docker swarm mode

Being a proxy for an S3 backend, s3proxy is designed to run smoothly with docker swarm mode.
Instances can be spawn safely in any node of your swarm as they are effectively stateless.

You can always use plain environment variables in your compose or stack file, but the image
supports docker secrets so your credentials are safe and swarm ready.

By default the image will try to load /run/secrets/secrets before launching tomcat.
The file must be a shell script exporting your environment variables.

For example:

    #!/bin/bash
    
    export AWS_ACCESS_KEY_ID=my-aws-access-key
    export AWS_SECRET_KEY=my-aws-secret-key
    export AWS_REGION=default-aws-region 
    export S3PROXY_AWS_BUCKET=my-bucket-name
    export S3PROXY_ADMIN_USERNAME=my-admin-username
    export S3PROXY_ADMIN_PASSWORD=my-admin-password


You can override the file location and name by setting the SECRETS_FILE environment variable
to the full path of the mounted secrets file.

## Exposed ports and volumes

The image exposes Tomcat http connector on port 8080, and Tomcat AJP connector on 8009.


The image defines a volume for the /var/lib/s3proxy/cache folder, which is used to store
the cache files and database. This is useful to keep the cache file when an image is upgraded 
or restarted in the same node.
## License

s3proxy is Open Source licensed under the Apache 2.0 license.

View [license information](https://www.apache.org/licenses/LICENSE-2.0) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses 
(such as Bash, etc from the base distribution, along with any direct or 
indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that 
any use of this image complies with any relevant 
licenses for all software contained within.
