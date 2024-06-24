# Install brew
sudo apt install build-essential procps curl file git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install mkcert
brew install mkcert
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> $HOME/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Create folder for vaultwarden
sudo mkdir -p /docker/vaultwarden/certs	/docker/vaultwarden/vw-data
sudo chown -R konoval:docker /docker

# Create CA and certificate for vw.local
cd /docker/vaultwarden/certs
mkcert -install
mkcert -key-file vw.local-private-key.pem -cert-file vw.local.pem vw.local

# Create docker - compose file
cd /docker/vaultwarden/
cat << 'EOF' > docker-compose.yml
version: '3.8'

services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    environment:
      WEBSOCKET_ENABLED: 'true'
      SIGNUPS_ALLOWED: 'true'
      DOMAIN: 'https://vw.local'
    volumes:
      - ./vw-data/:/data/
      - ./certs/:/certs/
    ports:
      - '443:443'

  caddy:
    image: caddy:2
    container_name: caddy
    restart: unless-stopped
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./certs:/certs
    ports:
      - '9091:443'
    depends_on:
      - vaultwarden
EOF

# Create CaddyFile
cat << 'EOF' > Caddyfile
vw.local {
    reverse_proxy vaultwarden:80
    tls /certs/vw.local.pem /certs/vw.local-private-key.pem
}
EOF

# Start vaultwarden
docker compose up -d
