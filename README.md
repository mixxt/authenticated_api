AuthenticatedApi
====
AuthenticatedApi is a Gem that helps you with sending and verifying HMAC signed requests.
The signature algorithm is taken from [Amazons SimpleDB](http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/HMACAuth.html)
but will maybe be changed to the [AWS S3 RestAuthentication](http://s3.amazonaws.com/doc/s3-developer-guide/RESTAuthentication.html) in the future.

Signing a request
----
Send a signed request with `Net::HTTP` and `AuthenticatedApi::Client`:

```ruby
    # creates a small wrapper around Net::HTTP that signs requests through #request
    client = AuthenticatedApi::Client.new('api.example.org', 80, 'your_access_key', 'shared_secret')
    # create a get request and sign it with our shared secret
    response = client.request(Net::HTTP::Get.new(file_request))
```

Verifying a request
----
Use the `AuthenticatedApi::Server` to verify a `Rack::Request`

```ruby
    # check if the signature of a Rack::Request compatible object was created with the shared_secret
    AuthenticatedApi::Server.valid_signature?(request, shared_secret)
```

Verify with the Middleware
----
Use the `AuthenticatedApi::Server::Middleware` to verify every incoming request using a predefined Account Hash

```ruby
    # Add this to your Middleware Stack

    # defines the shared_secret for every possible AccessKeyID
    accounts = {
        'my_account' => 'my_shared_secret'
    }
    # the middleware sets the env['api.authorized'] flag to true if the signature could be verified
    use AuthenticatedApi::Server::Middleware,
      accounts,
      {force: true} # if force is set to true it will abort invalid requests with 403 immediately
```

Generating the signature for a request by hand
----
If you are using ruby you can use the `AuthenticatedApi::Signature` class to generate a signature:

```ruby
    # params for construtor: method (case insensitive), host (case insensitive), path, params (query/get and body/post)
    AuthenticatedApi::Signature.new('get', 'Example.com', '/', {'something' => 'value'}).sign_with(secret)
```

If you cannot use the Helper class, see the [Amazons SimpleDB](http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/HMACAuth.html) developer guide on how to generate a Signature.
The required params for AuthenticatedApi are Signature and AccessKeyID.

Compatibility
----
AuthenticatedApi is tested with MRI 1.9.3, nothing else yet.

Origin
----
This project is a fork of the [api-auth gem](https://github.com/mgomes/api_auth) gem, but has changed significantly.
