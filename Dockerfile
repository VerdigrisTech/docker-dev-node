FROM bitnami/minideb:bullseye AS builder
ARG NODE_MAJOR_VERSION=16

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /tmp
RUN install_packages ca-certificates curl gnupg jq xz-utils
RUN gpg --keyserver hkps://keys.openpgp.org --recv-keys 4ED778F539E3634C779C87C6D7062848A1AB005C \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys 141F07595B7B3FFE74309A937405533BE57C7D57 \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys 94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys 74F12602B6F1C4E913FAA37AD3A89613643B6201 \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys 71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys 61FC681DFB92A079F1685E77973F295594EC4689 \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys 8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys 890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys 108F52B48DB57BB0CC439B2997B01419BD92F80A \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys B9E2F5981AA6E0CD28160D9FF13993A75599653C

# Query the index to get the latest version from major version
RUN curl -sSLO https://nodejs.org/dist/index.json
RUN case "$(dpkg --print-architecture)" in \
    amd64) arch="x64";; \
    i386) arch="x86";; \
    *) arch="$(dpkg --print-architecture)";; \
  esac; \
  version=$(cat index.json | jq -r "map(select(.lts and (.version | startswith(\"v${NODE_MAJOR_VERSION}.\"))))[0].version"); \
  package=node-${version}-linux-${arch}; \
  # Verify the Node.js binary before expanding the file
  curl -sSLO "https://nodejs.org/dist/${version}/SHASUMS256.txt.sig"; \
  curl -sSLO "https://nodejs.org/dist/${version}/SHASUMS256.txt"; \
  gpg --verify SHASUMS256.txt.sig SHASUMS256.txt; \
  curl -sSLO "https://nodejs.org/dist/${version}/${package}.tar.xz"; \
  grep ${package}.tar.xz SHASUMS256.txt | sha256sum -c - \
  # Extract Node.js tarball
  && tar xvf ${package}.tar.xz \
  && cp -R ./${package}/* /usr/local

FROM verdigristech/dev-base:bullseye

COPY --from=builder /usr/local/ /usr/local/
