FROM sykuang/wine-x11-novnc
MAINTAINER Ken Kuang "sykuang.tw@gmail.com"

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV WINEARCH win32
ENV DISPLAY :0
ENV WINEPREFIX /home/docker/.wine
ENV HOME /home/docker/
ENV PYVER 3.8.3
# Updating and upgrading a bit.
# Install vnc, window manager and basic tools
USER docker
RUN WINEARCH=win32 wine wineboot && \
    umask 0 && mkdir /tmp/helper && cd /tmp/helper && \
    curl -LOO \
    https://www.python.org/ftp/python/${PYVER}/python-${PYVER}.exe \
    https://github.com/upx/upx/releases/download/v3.95/upx-3.95-win32.zip \
    && \
    xvfb-run sh -c "\
    wine python-${PYVER}.exe /quiet TargetDir=C:\\Python3 \
    Include_doc=0 InstallAllUsers=1 PrependPath=1; && \
    wineserver -w" && \
    unzip upx*.zip && \
    mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/ && \
    cd .. && rm -Rf helper
USER root
# Add supervisor conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add entrypoint.sh
ADD entrypoint.sh /etc/entrypoint.sh


## Add novnc
ENTRYPOINT ["/bin/bash","/etc/entrypoint.sh"]
# Expose Port
EXPOSE 8080 22
