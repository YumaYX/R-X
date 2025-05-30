

serve:
	podman run -v $$PWD:/app --workdir /app -p 8080:8080 ghcr.io/getzola/zola:v0.20.0 serve --interface 0.0.0.0 --port 8080 --base-url localhost

build:
	podman run -it -v $$PWD:/app:z --workdir /app ghcr.io/getzola/zola:v0.20.0 build

init:
	podman run -it -v $$PWD:/app:z --workdir /app ghcr.io/getzola/zola:v0.20.0 init .
