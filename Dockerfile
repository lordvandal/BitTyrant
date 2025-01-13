# Pull base image
FROM jlesage/baseimage-gui:alpine-3.15

WORKDIR /

# Install JDK
RUN echo "Installing OpenJDK..." && \
    add-pkg openjdk11 curl bash gtk+2.0

# Change default shell from ash to bash
RUN sed-patch 's/\/bin\/ash/\/bin\/bash/g' /etc/passwd

# Install BitTyrant
RUN echo "Downloading BitTyrant..." && \
    mkdir azureus && \
    curl -# -L http://bittyrant.cs.washington.edu/dist_090607/BitTyrant-Linux64.tar.bz2 | tar -xj --strip 1 -C azureus && \
    sed-patch 's/JAVA_PROGRAM_DIR=\"/JAVA_PROGRAM_DIR=\"\/usr\/bin\//' /azureus/azureus &&\
    chmod +x /azureus/azureus

# Copy the start script
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

# Copy init.d file
COPY bittyrant.sh /etc/cont-init.d/bittyrant.sh
RUN chmod +x /etc/cont-init.d/bittyrant.sh

# Adjust the openbox config.
RUN \
    # Maximize only the main/initial window.
    sed-patch 's/<application type="normal">/<application type="normal" title="BitTyrant">/' \
        /etc/xdg/openbox/rc.xml && \
    # Make sure the main window is always in the background.
    sed-patch '/<application name="BitTyrant" class"*" type="normal">/a \    <layer>below</layer>' \
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
