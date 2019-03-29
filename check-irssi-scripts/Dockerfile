FROM debian:9-slim

LABEL "com.github.actions.name"="Check Irssi Scripts" \
      "com.github.actions.description"="Checks Irssi Scripts" \
      "com.github.actions.icon"="server" \
      "com.github.actions.color"="gray-dark" \
\
      "repository"="http://github.com/ailin-nemui/actions-irssi" \
      "homepage"="http://github.com/ailin-nemui/actions-irssi" \
      "maintainer"="Irssi staff <staff@irssi.org>"

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		git \
		zsh \
		wget \
		gnupg \
		\
		build-essential \
		cpanminus \
		\
		liblwp-protocol-https-perl \
		libglib2.0-0 \
		libutf8proc2 \
		libotr5 \
	&& rm -rf /var/lib/apt/lists/*

ADD cpanfile /cpan/cpanfile

ENV PERL_MM_NONINTERACTIVE="1"

RUN cpanm --quiet --installdeps --notest /cpan \
	&& rm -fr /root/.cpanm

ADD docker-irssi.dpkg.cfg /etc/dpkg/dpkg.cfg.d/docker-irssi

ADD entrypoint.sh /entrypoint.sh
ADD runner.pl /runner.pl
ENTRYPOINT ["/entrypoint.sh"]
