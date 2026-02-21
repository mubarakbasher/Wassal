FROM ubuntu:22.04

# Install FreeRADIUS with PostgreSQL support and utilities
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    freeradius freeradius-postgresql freeradius-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Enable SQL module and sqlcounter
RUN ln -sf /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/sql
RUN ln -sf /etc/freeradius/3.0/mods-available/counter_session_time /etc/freeradius/3.0/mods-enabled/counter_session_time

# Copy custom config files
COPY raddb/mods-available/sql /etc/freeradius/3.0/mods-available/sql
COPY raddb/mods-available/counter_session_time /etc/freeradius/3.0/mods-available/counter_session_time
COPY raddb/sites-available/default /etc/freeradius/3.0/sites-available/default
COPY raddb/clients.conf /etc/freeradius/3.0/clients.conf

# FreeRADIUS runs as freerad user
RUN chown -R freerad:freerad /etc/freeradius/3.0/

# Expose RADIUS ports
EXPOSE 1812/udp 1813/udp

# Run in foreground mode
CMD ["freeradius", "-f"]
