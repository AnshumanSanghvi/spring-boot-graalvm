# Simple Dockerfile adding Maven and GraalVM Native Image compiler to the standard
# https://github.com/orgs/graalvm/packages/container/package/graalvm-ce image
FROM ghcr.io/graalvm/graalvm-ce:ol7-java11-20.3.1.2

ADD . /build
WORKDIR /build

# For SDKMAN to work we need unzip & zip
RUN yum install -y unzip zip

# The official GraalVM Docker image from Oracle lacks both Maven and the native-image GraalVM plugin.
RUN \
    # Install SDKMAN
    curl -s "https://get.sdkman.io" | bash; \
    source "$HOME/.sdkman/bin/sdkman-init.sh"; \
    sdk install maven; \
    # Install GraalVM Native Image
    gu install native-image;

RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && mvn --version

RUN native-image --version

RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && mvn -B clean package -Pnative-image --no-transfer-progress


# We use a Docker multi-stage build here in order that we only take the compiled native Spring Boot App from the first build container.
# This container only uses 180 mb, The native application will run on this container
FROM oraclelinux:7-slim

# Copy Spring Boot Native app graalVM from Container 0 to new Container
COPY --from=0 "build/target/graalVM" graalVM

# Fire up our Spring Boot Native app by default
CMD [ "sh", "-c", "./graalVM -Dserver.port=$PORT" ]