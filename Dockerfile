# Pull base image
FROM jlesage/baseimage-gui:alpine-3.12

# Install JDK
RUN echo "Installing OpenJDK..." && \
    add-pkg openjdk11 curl

# Install BitTyrant
RUN echo "Downloading BitTyrant..." && \
    mkdir azureus && \
    curl -# -L http://bittyrant.cs.washington.edu/dist_090607/BitTyrant-Linux64.tar.bz2 | tar -xj --strip 1 -C azureus

# Copy the start script
COPY startapp.sh /startapp.sh

# Copy init.d file
COPY bittyrant.sh /etc/cont-init.d/bittyrant.sh

# Adjust the openbox config.
RUN \
    # Maximize only the main/initial window.
    sed-patch 's/<application type="normal">/<application type="normal" title="BitTyrant">/' \
        /etc/xdg/openbox/rc.xml && \
    # Make sure the main window is always in the background.
    sed-patch '/<application type="normal" title="BitTyrant">/a \    <layer>below</layer>' \
        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/lordvandal/bittyrant/main/bittyrant.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Set the name of the application
ENV APP_NAME="BitTyrant"

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/storage"]
