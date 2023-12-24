GIT_DESC:=$(shell git describe --exclude "*" --always --long)
IMAGE:=quay.io/yushiwho/api:$(GIT_DESC)

build:	
	docker build --tag $(IMAGE)  .

push:
	docker push $(IMAGE)

shell:
	docker run --rm -it --name api --entrypoint bash ${IMAGE}

run:
	docker run -p 5000:5000  --rm -it --name api ${IMAGE}
