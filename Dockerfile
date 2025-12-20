FROM amazonlinux:2023

RUN dnf install -y dnf-plugins-core shadow-utils && \
    dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

RUN dnf -y install vault awscli jq && \
    dnf clean all

COPY scripts/ /scripts/
