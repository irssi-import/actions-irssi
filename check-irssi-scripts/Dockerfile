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
		\
		libdb-dev \
		libaspell-dev \
		libgirepository1.0-dev \
		libexpat1-dev \
		gobject-introspection \
		gir1.2-notify-0.7 \
		xosd-bin \
		wbritish \
		\
		perl-tk \
		libcrypt-ssleay-perl \
		liblwp-online-perl \
		libauthen-sasl-perl \
		libtest-utf8-perl \
		libfeed-find-perl \
	&& rm -rf /var/lib/apt/lists/*
# (1) action dependencies
# (2) CPAN dependencies
# (3) Irssi dependencies
# (4) script dependencies
# (5) some Perl modules from auto.cpanfile
# gir1.2-notify-0.7 for desktop-notify
# xosd-bin          for osd
# wbritish          for dictcomplete

ENV PERL_MM_NONINTERACTIVE="1"

ADD cpanfile /cpan/cpanfile
RUN cpanm --quiet --installdeps --notest /cpan \
	&& rm -fr /root/.cpanm

# to be updated periodically
ADD auto.cpanfile /autocpan/cpanfile
RUN cpanm --quiet --installdeps --notest /autocpan \
	&& rm -fr /root/.cpanm

ADD docker-irssi.dpkg.cfg /etc/dpkg/dpkg.cfg.d/docker-irssi

ADD entrypoint.sh /entrypoint.sh
ADD runner.pl /runner.pl
ENTRYPOINT ["/entrypoint.sh"]
