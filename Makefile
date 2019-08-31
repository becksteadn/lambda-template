build:
	cd function; \
	mkdir build; \
	cp main.py build/; \
	pip3 install -r requirements.txt -t build/; \
	cd build; zip -9qr build.zip .; \

apply:
	terraform apply

update: build
	terraform apply
