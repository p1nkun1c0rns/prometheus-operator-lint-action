FROM golang:alpine3.11

LABEL name="prometheus-operator-lint-action"
LABEL repository="http://github.com/p1nkun1c0rns/prometheus-operator-lint-action"
LABEL homepage="http://github.com/p1nkun1c0rns/prometheus-operator-lint-action"
LABEL maintainer="Richard Steinbrueck <richard.steinbrueck@googlemail.com>"

ENV GO111MODULE on
ENV PO_LINT_VERSION 0.38.0

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# hadolint ignore=DL3018
RUN apk add --no-cache \
        git

RUN go get -u github.com/coreos/prometheus-operator/cmd/po-lint@v${PO_LINT_VERSION}

ENTRYPOINT [ "/entrypoint.sh" ]
