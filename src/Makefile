# TODO find better use for TAG
#date_tag_daily := $(shell date +%m%d%y)

build-binary-container:
	docker build -t caddylinux-bin -f Dockerfile --build-arg TAG=latest --build-arg OS=linux . --target builder
#multi-build-binary:
#	docker build -t caddylinux-bin -f Dockerfile --build-arg TAG=$(date_tag_daily) --build-arg OS=linux . --target builder
#	docker build -t caddydarwin-bin -f Dockerfile --build-arg TAG=$(date_tag_daily) --build-arg OS=darwin . --target builder
#	docker build -t caddywindows-bin -f Dockerfile --build-arg TAG=$(date_tag_daily) --build-arg OS=windows . --target builder
build:
	docker build -t caddylinux -f Dockerfile --build-arg TAG=latest --build-arg OS=linux --build-arg TARGET_PORT=8080 .
extract:
	docker run --rm --name caddybin caddylinux-bin; docker cp caddybin:/go/bin/caddy . && docker rm -f caddybin
run:
	docker run -p 8080:8080 --name caddylinux caddylinux &
clean:
	docker rm -f caddylinux
