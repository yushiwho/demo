GIT_DESC:=$(shell git describe --exclude "*" --always --long)
IMAGE:=quay.io/yushiwho/sys-stats:$(GIT_DESC)

build:	
	docker build --tag $(IMAGE)  .

push:
	docker push $(IMAGE)

shell:
	docker run --rm -it --name sys-stats --entrypoint sh ${IMAGE}

run:
	docker run -p 8082:80  --rm -it --name sys-stats ${IMAGE}
