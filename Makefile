DOCKER_COMPOSE=docker compose -f docker-compose.yml
BUNDLE_FLAGS=
CERTIFICATE_PATH=radius_test_certificates

ROOT=smoke_test_root_ca
INTERMEDIATE=smoke_test_intermediate_ca
CLIENT=smoke_test_client
VALID_FOR=9000

build:
	$(DOCKER_COMPOSE) build

lint: build
	$(DOCKER_COMPOSE) run --rm app bundle exec rubocop

test-radius: build
	$(DOCKER_COMPOSE) run --rm \
		-e DOCKER=docker \
		-e RADIUS_KEY \
		-e RADIUS_IPS \
		-e SUBDOMAIN \
		-e EAP_TLS_CLIENT_CERT \
		-e EAP_TLS_CLIENT_KEY \
		app bundle exec rspec spec/system/radius

stop:
	$(DOCKER_COMPOSE) down -v

shell: build
	$(DOCKER_COMPOSE) run --rm \
		-e DOCKER=docker \
		-e RADIUS_KEY \
		-e RADIUS_IPS \
		-e SUBDOMAIN \
		-e EAP_TLS_CLIENT_CERT \
		-e EAP_TLS_CLIENT_KEY \
		 app bundle exec sh

certs:
	mkdir -p $(CERTIFICATE_PATH)
	openssl req -x509 -newkey rsa:4096 -keyout $(CERTIFICATE_PATH)/$(ROOT).key -out $(CERTIFICATE_PATH)/$(ROOT).pem -sha256 -days $(VALID_FOR) -nodes -subj '/CN=Smoke Test Root CA'

	openssl req -newkey 4096 -keyout $(CERTIFICATE_PATH)/$(INTERMEDIATE).key -outform pem -keyform pem -out $(CERTIFICATE_PATH)/$(INTERMEDIATE).req -nodes -subj '/CN=Smoke Test Intermediate CA'
	openssl x509 -req -CA $(CERTIFICATE_PATH)/$(ROOT).pem -CAkey $(CERTIFICATE_PATH)/$(ROOT).key -in $(CERTIFICATE_PATH)/$(INTERMEDIATE).req -out $(CERTIFICATE_PATH)/$(INTERMEDIATE).pem -extensions v3_ca -days $(VALID_FOR) -CAcreateserial -extfile openssl.conf -CAserial $(CERTIFICATE_PATH)/intermediate.srl

	openssl req -newkey 4096 -keyout $(CERTIFICATE_PATH)/$(CLIENT).key -outform pem -keyform pem -out $(CERTIFICATE_PATH)/$(CLIENT).req -nodes -subj '/CN=Client'
	openssl x509 -req -CA $(CERTIFICATE_PATH)/$(INTERMEDIATE).pem -CAkey $(CERTIFICATE_PATH)/$(INTERMEDIATE).key -in $(CERTIFICATE_PATH)/$(CLIENT).req -out $(CERTIFICATE_PATH)/$(CLIENT).pem -extensions v3_client -days $(VALID_FOR) -CAcreateserial -extfile openssl.conf -CAserial $(CERTIFICATE_PATH)/client.srl
	rm -f $(CERTIFICATE_PATH)/*.req

.PHONY: build stop test shell
