## Dockerfile for a pandoc environment
## Cf. https://github.com/jagregory/pandoc-docker/blob/master/Dockerfile
## from James Gregory <james@jagregory.com>
FROM       dgricci/haskell:1.0.0
MAINTAINER Didier Richard <didier.richard@ign.fr>
LABEL       version="1.0.0" \
            pandoc="v2.2.3.2" \
            os="Debian Stretch" \
            description="Pandoc environment with the following packages installed : pandoc-include, pandoc-include-code, pandoc-placetable"

## different versions - use argument when defined otherwise use defaults
# Cf. https://hackage.haskell.org/package/pandoc for pandoc version
ARG PANDOC_VERSION
ENV PANDOC_VERSION      ${PANDOC_VERSION:-2.2.3.2}
ARG PANDOC_INCLUDE_CODE
ENV PANDOC_INCLUDE_CODE ${PANDOC_INCLUDE_CODE:-1.3.0.0}
ARG PANDOC_PLACETABLE
ENV PANDOC_PLACETABLE   ${PANDOC_PLACETABLE:-0.5}

COPY build.sh /tmp/build.sh
RUN /tmp/build.sh && rm -f /tmp/build.sh

# default command : launch pandoc's version
CMD ["pandoc", "--version"]

