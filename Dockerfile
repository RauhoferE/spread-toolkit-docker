FROM archlinux:latest

# Install 32-bit compatibility libraries and tar
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm libnsl tar gzip && \
    # Clean up the package cache to keep the image smaller (critical for Arch/Manjaro)
    pacman -Scc --noconfirm

# Create directory for Spread
WORKDIR /opt

COPY spread-bin-4.0.0.tar.gz /opt/spread-bin-4.0.0.tar.gz

RUN tar -xzf spread-bin-4.0.0.tar.gz && \
    rm spread-bin-4.0.0.tar.gz

# Create the 'spread' user and group
RUN groupadd spread && \
    useradd -g spread -s /bin/sh -d /opt/spread-bin-4.0.0 spread && \
    chown -R spread:spread /opt/spread-bin-4.0.0

# Set environment variables
ENV SPREAD_HOME=/opt/spread-bin-4.0.0
ENV PATH=$SPREAD_HOME/bin/x64:$PATH

# Copy and configure spread.conf
COPY conf/spread.conf /etc/spread/spread.conf
RUN chown spread:spread /etc/spread/spread.conf

# Expose Spread default port
EXPOSE 4803

# Run Spread as the 'spread' user by default
USER spread

ENTRYPOINT [ "spread", "-c", "/etc/spread/spread.conf" ]
