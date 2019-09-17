FROM opensuse/leap

# General information
LABEL de.itsfullofstars.sapnwdocker.version="1.1.0"
LABEL de.itsfullofstars.sapnwdocker.vendor="Eduardo Copat"
LABEL de.itsfullofstars.sapnwdocker.name="Docker for SAP NetWeaver 7.5x Developer Edition"

# Install dependencies
RUN zypper --non-interactive install --replacefiles  uuidd expect tcsh which iputils vim hostname tar net-tools iproute2 gzip libaio1 libstdc++6 glibc*

# Run uuidd
RUN mkdir /run/uuidd && chown uuidd /var/run/uuidd && /usr/sbin/uuidd

# Copy the downloaded and unrared SAP NW ABAP files to the container
COPY NW751 /tmp/NW751/

# We will work from /tmp/NW751
WORKDIR /tmp/NW751

# Make the install.sh from SAP executable
RUN chmod +x install.sh

# Prepare the shell script to install NW ABAP without asking for user input (using expect)
# Note: Password being used is s@pABAP751
RUN echo vhcalnplci > /etc/hostname && echo $'#!/usr/bin/expect -f \n\
spawn ./install.sh -s -k \n\
expect "Your distribution \'opensuse-leap\' was not tested. Do you want to continue?"\n\
send "yes\\r"\n\
set PASSWORD "s@pABAP751"\n\
set timeout -1\n\
expect "Do you agree to the above license terms? yes/no:"\n\
send "yes\\r"\n\
expect "Please enter a password:"\n\
send "$PASSWORD\\r"\n\
expect "Please re-enter password for verification:"\n\
send  "$PASSWORD\\r"\n\
expect eof' >> ./run.sh; chmod +x ./run.sh


# Expose the ports to work with NW ABAP
EXPOSE 8000
EXPOSE 44300
EXPOSE 3300
EXPOSE 3200

# We cannot run the automated installation, as Docker gives no more space left on device error message
# Note: running the script run.sh after the image is created will work
# RUN ./run.sh

# Command sequence to use this Dockerfile

# docker build -t nwabap .
# docker run -P -h vhcalnplci --publish 3200:3200 --publish 3300:3300 --publish 8000:8000 --publish 44300:44300 --name nwabap751 -it nwabap:latest /bin/bash
#


# Start the SAP system:
# /usr/sbin/uuidd
# Switch to user npladm with default password Appl1ance in the console : su npladm
# Start the SAP system : startsap ALL