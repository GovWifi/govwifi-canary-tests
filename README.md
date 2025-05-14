# GovWifi Canary Tests

This is a collection of rspec with Capybara tests.

## Running radius tests

The tests run inside a Docker container. You need to provide some environment variables:

- `RADIUS_KEY` - Key to allow access to radius, this is located in the admin app > org > locations
- `RADIUS_IPS` - allow list for radius, again located in the admin app > org > locations
- `EAP_TLS_CLIENT_CERT` -  Radius client cert
- `EAP_TLS_CLIENT_KEY` - Radius client key

An example of setting the environment variables
```
export RADIUS_KEY=abcdefghijklmnopqrstuvwxyz1234567890
export RADIUS_IPS=1.2.3.4,66.7.90.9
export EAP_TLS_CLIENT_CERT="-----BEGIN CERTIFICATE-----\nMIIFE...nXuwl58=\n-----END CERTIFICATE-----\n"
export EAP_TLS_CLIENT_KEY="-----BEGIN PRIVATE KEY-----\nMIIJKJ...F\niaAt+83-----END PRIVATE KEY-----\n"
```

You can find the values of the environment variables in AWS secrets manager:
- `RADIUS_KEY` - deploy/radius_key
- `RADIUS_IPS` - smoke_tests/radius_ips/london
- `EAP_TLS_CLIENT_CERT` - smoke_tests/certificates/public
- `EAP_TLS_CLIENT_KEY` - smoke_tests/certificates/private

Then run the tests:
```make test-radius```

Particularly when running in an automated remote way, these credentials should be for a dummy organisation/account, with limited access.

You can also run outside of Docker. First you should install dependencies:
```
bundle install
```

Then similar to above, except you run rspec directly:
```
bundle exec rspec
```

## Running The Canary(smoke) Tests In Our Environments

The smoke tests have now been migrated from Concourse to AWS. [Full instructions on how to run and edit the infrastructure around them can be found here](https://docs.google.com/document/d/1RHNkGxJLr4BPPUlFgqDzCF6mSOXK0Kj2Yfb-GHXXNIA/). You will need to be a member of the GovWifi Team in order to access this guide.

## New Environments
If creating smoke tests on new environments, ensure to create new secrets for all appropriate fields, also new templates in Notify will need creating, as well as API keys.  For Radius ensure that it knows about the ```task``` ip's as well as the smoke test org ip's ```<env>.wifi-smoke-tests-x```, these will need to be entered into the Admin App for the Smoke Test Org.

### Generating the TLS certificates to test the CBA user Journey

The smoketests require that dummy certificates are generated to function correctly. You will need to create these if you are setting up a new GovWifi environment from scratch or testing locally. They are referenced through environment variables in the EAP TLS journey ([code](https://github.com/GovWifi/govwifi-smoke-tests/blob/cfb97ee543514209989e53b9001644c839570cc3/spec/system/signup/eap_tls_journey_spec.rb#L8-L14)) and they are referenced in the [govwifi-terraform code](https://github.com/GovWifi/govwifi-terraform/blob/f0fc070b4d0d281f8d721c64bf823b9fddf0cb0b/govwifi-smoke-tests/codebuild.tf#L110-L118)

You can generate them with the following steps:

* Make a directory called `radius_test_certificates` or the directory name set in [this line of the Makefile](https://github.com/GovWifi/govwifi-smoke-tests/blob/4a182cbf609c43c4407dbea87ea956633d470c6c/Makefile#L3)
* Run `make certs` in your terminal
(If you need to edit these commands they can be found in [this section of the Smoketests Makefile](https://github.com/GovWifi/govwifi-smoke-tests/blob/4a182cbf609c43c4407dbea87ea956633d470c6c/Makefile#L65-L74))

If you are setting up a new GovWifi environment add these certificates to AWS secret manager. Name the secrets `smoke_tests/certificates/public` for the public key and `smoke_tests/certificates/private` for the private key. 

[You can read more about CBA(Certificate Based Authentication) in our team manual](https://dev-docs.wifi.service.gov.uk/about-govwifi/device-wifi.html#what-is-it)

