FROM fedora:32

RUN dnf -y update && dnf clean all
RUN dnf -y install libabigail && dnf clean all

ENTRYPOINT ["/usr/bin/abipkgdiff"]
