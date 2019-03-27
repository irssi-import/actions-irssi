FROM debian:9-slim

LABEL "com.github.actions.name"="Check Irssi"
LABEL "com.github.actions.description"="Checks Irssi C code"
LABEL "com.github.actions.icon"="server"
LABEL "com.github.actions.color"="gray-dark"

LABEL "repository"="http://github.com/ailin-nemui/actions-irssi"
LABEL "homepage"="http://github.com/ailin-nemui/actions-irssi"
LABEL "maintainer"="Irssi staff <staff@irssi.org>"

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		git \
		autoconf \
		automake \
		libtool \
		make \
		\
		libglib2.0-dev \
		libperl-dev \
		libtinfo-dev \
		libssl-dev \
		libotr5-dev \
		libutf8proc-dev \
	&& rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh
ADD runner.pl /runner.pl
ADD render.pl /tools/render.pl
ENTRYPOINT ["/entrypoint.sh"]
