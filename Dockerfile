FROM python:2.7-alpine

ARG PACKER_VER=1.2.4

RUN apk --no-cache add jq sed bash \
  && pip install awscli --upgrade \
  && wget -O /tmp/packer.zip \
    "https://releases.hashicorp.com/packer/${PACKER_VER}/packer_${PACKER_VER}_linux_amd64.zip" \
  && unzip -o /tmp/packer.zip -d /usr/local/bin \
  && rm -f /tmp/packer.zip

ADD assets /opt/resource

CMD []
