grails {
    plugin {
        awssdk {
            accessKey = System.getenv( "AWS_ACCESS_KEY_ID" )
            secretKey = System.getenv( "AWS_SECRET_KEY" )
            region = System.getenv( "AWS_REGION" )
        }
    }
}
