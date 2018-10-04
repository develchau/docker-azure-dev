FROM centos:7

LABEL maintainer="develchau@hotmail.com"

ARG VCF_REF
ARG BUILD_DATE

LABEL org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.license="MIT"

ARG MYUSERNAME=developer
ARG MYUID=2000
ARG MYGID=200
ENV MYUSERNAME=${MYUSERNAME} \
    MYUID=${MYUID} \
    MYGID=${MYGID} 

# Setup locale
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8
RUN echo -e "export LANG=en_US.UTF-8\nexport LANGUAGE=en_US.UTF-8\nexport LC_CTYPE=en_US.UTF-8\nexport LC_ALL=en_US.UTF-8" > /etc/profile.d/lang.sh && \ 
    echo -e "LANG=en_US.UTF-8" > /etc/sysconfig/i18n && \
    echo -e "LANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8" >> /etc/environment && \
    source /etc/profile.d/lang.sh

# Update packages
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum update -y && \
    yum install curl sudo gcc-c++ make which -y && \
    yum groupinstall 'Development Tools' -y && \
    yum install gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel -y

# Install fonts
RUN yum install cabextract xorg-x11-font-utils fontconfig fonts-chinese fonts-ISO8859-2-75dpi -y && \
    rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Install git 2 and nodejs and python
RUN yum remove git -y && \
    yum install https://centos7.iuscommunity.org/ius-release.rpm -y && \
    yum install git2u -y && \
    curl --silent --location https://rpm.nodesource.com/setup_8.x | bash - && \
    yum install nodejs -y && \
    yum install -y python36u python36u-libs python36u-devel python36u-pip

# Create profile
RUN echo 'Creating user: ${MYUSERNAME} wit UID $UID' && \
    mkdir -p /home/${MYUSERNAME} && \
    echo "${MYUSERNAME}:x:${MYUID}:${MYGID}:Developer,,,:/home/${MYUSERNAME}:/bin/bash" >> /etc/passwd && \
    echo "${MYUSERNAME}:x:${MYGID}:" >> /etc/group && \
    echo "${MYUSERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${MYUSERNAME} && \
    chmod 0440 /etc/sudoers.d/${MYUSERNAME} && \
    chown ${MYUSERNAME}:${MYUSERNAME} -R /home/${MYUSERNAME} && \
    chown root:root /usr/bin/sudo && \
    chmod 4755 /usr/bin/sudo && \
    usermod -aG wheel ${MYUSERNAME}

# Install Azure CLI
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo && \
    yum install azure-cli -y

# Install vscode
RUN echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo && \
    yum install code -y

# Install vscode extensions
RUN su ${MYUSERNAME} -c 'code --install-extension ms-azuretools.vscode-azurefunctions'

ENV HOME /home/${MYUSERNAME}
ENV TERM=xterm

WORKDIR /home/${MYUSERNAME}    

# CMD ["vscode"]