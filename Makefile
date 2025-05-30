ZOLA_IMAGE=ghcr.io/getzola/zola:v0.20.0
VOLUME=-v $$PWD:/app:z
WORKDIR=--workdir /app
RUN=podman run $(VOLUME) $(WORKDIR)

serve:
	$(RUN) -p 8080:8080 $(ZOLA_IMAGE) serve --interface 0.0.0.0 --port 8080 --base-url localhost/R-X/

build:
	$(RUN) $(ZOLA_IMAGE) build

init:
	podman run -it $(VOLUME) $(WORKDIR) $(ZOLA_IMAGE) init .

