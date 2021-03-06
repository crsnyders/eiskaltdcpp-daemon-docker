FROM alpine:3.7 AS builder

RUN apk update && apk add --no-cache binutils \
    gcc \
    g++ \
    make \
    libc-dev \
    fortify-headers \
    cmake \
    git \
    gettext \
    boost-dev \
    bzip2-dev \
    openssl-dev \
    pkgconfig \
    zlib-dev \
    gettext-dev

RUN cd /tmp && git clone --depth 1 https://github.com/eiskaltdcpp/eiskaltdcpp.git eiskaltdcpp-master
ADD alpine_build.patch /tmp/
RUN cd /tmp/eiskaltdcpp-master && git apply /tmp/alpine_build.patch

# eiskaltdcpp

RUN mkdir -p /tmp/eiskaltdcpp-master/builddir
RUN cd /tmp/eiskaltdcpp-master/builddir \
 && cmake  -DCMAKE_CXX_FLAGS='-I/opt/local/include' \
          -DCMAKE_BUILD_TYPE=Release \
          -DNO_UI_DAEMON=ON \
          -DJSONRPC_DAEMON=ON \
          -DLOCAL_JSONCPP=ON \
          -DUSE_QT=OFF \
          -DUSE_QT5=OFF \
          -DUSE_IDNA=OFF \
          -DFREE_SPACE_BAR_C=OFF \
          -DLINK=STATIC \
          -Dlinguas="" \
          -DGETTEXT_INTL_LIBRARY="/usr/lib/libintl.so" \
          ..
RUN cd /tmp/eiskaltdcpp-master/builddir \
 && make


# -----------------------------------------------------------------------------
# production image:
# -----------------------------------------------------------------------------
FROM alpine
COPY --from=builder /tmp/eiskaltdcpp-master/builddir/eiskaltdcpp-daemon/eiskaltdcpp-daemon \
                    /bin/

RUN apk update && apk add boost-system gettext libbz2 libcrypto1.0 libbz2 libintl libstdc++ libssl1.0


EXPOSE 3121/tcp
EXPOSE 2222/tcp

CMD ["eiskaltdcpp-daemon","-v"]
