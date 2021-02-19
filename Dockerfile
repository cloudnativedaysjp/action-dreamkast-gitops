FROM alpine:latest

RUN apk add --no-cache curl jq bash
RUN export KUSTOMIZE_VERSION=3.6.1 && \
      curl -sL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz -o /tmp/kustomize.tgz && \
      tar xvzf /tmp/kustomize.tgz -C /usr/local/bin/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
