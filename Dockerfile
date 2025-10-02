FROM golang:1.24-alpine AS build-image

COPY . /src/lambda-promtail
WORKDIR /src/lambda-promtail

RUN go mod download && \
    go build -o /main -tags lambda.norpc -ldflags="-s -w" pkg/*.go

# copy artifacts to a clean image
FROM public.ecr.aws/lambda/provided:al2
RUN yum -y update openssl-libs ca-certificates krb5-libs &&\
    yum clean all
COPY --from=build-image /main /main
ENTRYPOINT [ "/main" ]
