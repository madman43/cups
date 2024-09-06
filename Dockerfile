# syntax=docker/dockerfile:1

# Use the latest Ubuntu base image
FROM ubuntu:latest

# Set the working directory inside the container
WORKDIR /workspaces/cups

# Update package list and upgrade existing packages
RUN apt-get update -y && apt-get upgrade -y

# Install required dependencies for CUPS and openssl for password encryption
RUN apt-get install -y \
    autoconf \
    build-essential \
    libavahi-client-dev \
    libgnutls28-dev \
    libkrb5-dev \
    libnss-mdns \
    libpam-dev \
    libsystemd-dev \
    libusb-1.0-0-dev \
    zlib1g-dev \
    openssl \
    apt-utils \
    sudo

# Create a new user 'admin' with password 'admin'
# Generate the encrypted password and store it in a variable
RUN echo 'admin' | openssl passwd -1 -stdin > /tmp/passwd.txt && \
    useradd -m --create-home --password `cat /tmp/passwd.txt` admin && \
    rm /tmp/passwd.txt

# Create a new group 'lpadmin'
RUN groupadd lpadmin

# Add the user 'admin' to the 'lpadmin' group
RUN usermod -aG lpadmin admin

# Grant sudo privileges to the user 'admin'
RUN echo 'admin ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

# Copy the current directory contents into the container's working directory
COPY . .

# Build and install CUPS
RUN ./configure && make && make install

# Expose port 631 for CUPS web interface
EXPOSE 631

# Start the CUPS daemon for remote access
CMD ["/usr/sbin/cupsd", "-f"]
