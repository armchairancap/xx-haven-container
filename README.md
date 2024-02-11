- [xx Network Haven (formerly Speakeasy) container image](#xx-network-haven-formerly-speakeasy-container-image)
  - [About Haven](#about-haven)
    - [Haven Web application](#haven-web-application)
  - [Quick start for Public IPs with Let's Encrypt](#quick-start-for-public-ips-with-lets-encrypt)
  - [Slow start](#slow-start)
    - [Run Haven from prebuilt image](#run-haven-from-prebuilt-image)
    - [Build and run own image](#build-and-run-own-image)
  - [Deploy a reverse HTTPS proxy](#deploy-a-reverse-https-proxy)
  - [Deploy with Docker Compose](#deploy-with-docker-compose)
    - [Public IP with FQDN](#public-ip-with-fqdn)
    - [Internal (LAN) IP with internal hostname or localhost](#internal-lan-ip-with-internal-hostname-or-localhost)
    - [Haven as Hiden Service on .onion network](#haven-as-hiden-service-on-onion-network)
  - [Version and other container information](#version-and-other-container-information)
  - [License](#license)

# xx Network Haven (formerly Speakeasy) container image

## About Haven

[Haven](https://www.speakeasy.tech) is a privacy-first Web client for xx Network.

It uses WASM and xxDK to access random gateways on the cMix network. It provides unique online identities, quantum-resistant encrypted messaging and other features. See the Web site for more.

### Haven Web application

A Web server is required to download Haven application code. The site that serves it - such as [https://www.speakeasy.tech](https://www.speakeasy.tech) - may collect client IP addresses (which merely identifies the address as a Haven user or, if compromised, even serve malicious code - unlikely, but not impossible, to happen on the official Haven site).

Haven Web server is not involved in forwarding or encrypting client data: that happens exclusively on the client (in browser).

Haven server running clean code cannot determine the content of messages or even who are the parties who exchange messages:

- Messages are not exchanged on the Haven Web server
- Messages are created, routed through xxNetwork's cMix protocol, and received directly on the Web client

Each user can use their own Haven server - it is not necessary to access the common server. The only tip regarding this is when you get a "join channel" link, you can optionally modify it to replace the FQDN with your own FQDN, although it should work without that step.

This Haven container makes it easier to:

- Run own Haven server
- Removes the risk of the server operator recording your IP address (which merely identifies you as a user, not your cMix identity)
- Removes the risk of malicious (modified or hacked) application code on the server
- Makes Haven Web app easily accessible from internal or external application portals

Some deployment scenarios:

- Small (1GiB RAM) cloud VM with Docker running Haven container, reverse-proxied by Cloudflare or another container (NGINX, Traefik, Caddy, etc.) on the same VM
- Haven and HTTPS proxy container on your desktop, notebook or home server
- Home-hosted Haven opened to friends or colleagues over Tailscale network

Reverse HTTPS proxy requires no Haven-specific steps: just forward HTTPS to whatever port Haven container is exposed at.

## Quick start for Public IPs with Let's Encrypt

For this you need a public IP address, DNS A record for FQDN.

```sh
git clone https://github.com/armchairancap/xx-haven-container
cd xx-haven-container
vi docker-compose.yml
```

- Create a DNS A record for your FQDN such as haven.something.io
- In `docker-compose.yml` replace YOUR@EMAIL.COM and YO.UR.TLD with your values
- For ARM64, change the Haven image URL from `ghcr.io/armchairancap/haven:latest` to `ghcr.io/armchairancap/haven-arm64:latest`. Currently I don't build multi-arch images on GHCR
- Open firewall ports tcp/80 (needed for Let's Encrypt) and tcp/443 to the world

```sh
docker compose up
```

Visit your site at https://FQDN.

Foreground mode (used below) can be exited with `CTRL+C`.

Once you get everything (including HTTPS reverse proxy) in order, you may add `-d` to `docker compose up` run Haven in the background.

## Slow start 

If you want to run a public instance, use Quick Start (above). 

If you want to run a private instance or build your own, read on.

### Run Haven from prebuilt image

It is recommended to build your own image from this repository's Dockerfile (see further below), but you may use [Github Container Registry images](ghcr.io/armchairancap/haven:latest) built by me. 

Use a service port available on your system and change the first 3000 to another port if you like.

```sh
docker run -it --rm -p 0.0.0.0:3000:3000 --name haven ghcr.io/armchairancap/haven:latest npm run start
# use haven-arm64:latest for ARM64 hosts
```

That should start Haven container and expose its service at [http://localhost:3000](http://localhost:3000) (not *https*).

```sh
> speakeasy-web@0.3.4 start
> next start 

ready - started server on 0.0.0.0:3000, url: http://localhost:3000
```

Don't click on that link because you'll get nothing. Go to http://address:port from your Docker run command. I this example the command exposed Haven on the port 8080:

![Running Haven container](./images/running-container.png)

If you're stuck, make sure your browser didn't redirect you to **https**:// instead, and that the port is correct.

Although you can now access Haven, you **still need a reverse HTTPS proxy in front of it** in order to use it! It won't work over HTTP.

### Build and run own image

The source is over 1 GB large and the image over 1 GB. You may need more than 5 GB of free disk space to build.

The Speakeasy source code repository has its own Dockerfile. Clone the source code, and run `docker build .` to build it. 

After cloning the repo, go to its directory and build.

```sh
git clone https://git.xx.network/elixxir/speakeasy-web && cd speakeasy-web
docker build -t haven:latest .
docker run -it --rm -p 0.0.0.0:3000:3000 --name haven haven:latest npm run start
```

Alternatively, you may reference this older [Dockerfile](https://github.com/armchairancap/xx-haven-container/commit/966c6293592af093f40065e5c5c34c0100ddb833#diff-dd2c0eb6ea5cfc6c4bd4eac30934e2d5746747af48fef6da689e85b752f39557) that I used to use before, but keep in mind that it was hard-coded to use port 80 (instead of the common 3000). Of course, you may change it as you see fit.

Now you should be able to see the Haven Web server's home page when you visit http://localhost:3000. You still **need a reverse HTTPS proxy** in front of it in order to use it.

Once you get everything (including HTTPS reverse proxy) in order, you may add `-d` to `docker run` to run the container in the background.

## Deploy a reverse HTTPS proxy

Without HTTPS in front of Haven you will see the home page, but Haven will not work for messaging. You need to access Haven through HTTPS.

There is nothing Haven-specific about this, just remember to forward port on your your HTTPS proxy to whatever port you chose here (e.g. 3000).

Some popular approaches:

- [Caddy HTTPS with Let's Encrypt](https://caddyserver.com/docs/automatic-https)
- [Cloudflare HTTPS with Let's Encrypt](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes)
- [Tailscale HTTPS with Let's Encrypt](https://tailscale.com/kb/1153/enabling-https)

## Deploy with Docker Compose

### Public IP with FQDN

To run a Haven container using image `haven:dev` exposed at `http://localhost:38080`:

```yaml
services:
  haven:
    image: haven:dev
    container_name: "haven"
    entrypoint: ["npm", "run", "start"]
    ports:
      - "38080:3000"
```

HTTPS reverse proxy with TLS that forwards `https://hostname:443` (or similar) to `http://localhost:38080` (or whatever you chose) is the last remaining step. 

What follows is the same thing as Quick Start (at the top), again using the default port 3000 to keep it consistent with other examples and Node .

Replace YOUR@EMAIL.COM and YO.UR.TLD with something that works for you.

```yaml
version: "3.3"
services:
  reverse-proxy:
    image: traefik:v2.11
    container_name: "traefik"
    command:
      - "--api.insecure=false"
      - "--api.dashboard=false"
      - "--api.debug=false"
      - "--providers.docker=true"
      - "--log.LEVEL=INFO"
      - "--entryPoints.web.address=:80"
      - "--entryPoints.websecure.address=:443"
      - "--providers.docker.exposedbydefault=false"
      - "--certificatesresolvers.myresolver.acme.httpchallenge=true"
      - "--certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.myresolver.acme.email=YOUR@EMAIL.COM"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
    ports:
      - "443:443"
      - "80:80"
      - "8080:8080"
    volumes:
      - "./letsencrypt:/letsencrypt"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
  node-server:
    image: ghcr.io/armchairancap/haven:latest
    # image: ghcr.io/armchairancap/haven-arm64:latest # use this for ARM64
    container_name: "node-server"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.node-server.rule=Host(`YO.UR.TLD`)"
      - "traefik.http.routers.node-server.entrypoints=websecure"
      - "traefik.http.routers.node-server.tls.certresolver=myresolver"
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
      - "traefik.http.routers.redirs.rule=hostregexp(`{host:.+}`)"
      - "traefik.http.routers.redirs.entrypoints=web"
      - "traefik.http.routers.redirs.middlewares=redirect-to-https"
    entrypoint: ["npm", "run", "start"]
    ports:
      - "3000:3000"
```

- Your public (Internet) firewall must allow tcp/80 and tcp/443 to Traefik. tcp/8080 must not be open to Internet clients (that's Traefik admin port) and tcp/3080 either (HTTP address of Haven container).
- YO.UR.TLD must have a DNS A record for the Haven URL.
- Traefik will use its Let's Encrypt integration to automatically obtain a TLS certificate for YO.UR.TLD. Your TLS certificate will be stored in ./letsencrypt.
- Clients trying to access Haven at http://YO.UR.TLD will be redirected to https://YO.UR.TLD by Traefik, and from there Traefik will forward requests to http://node-server:3000 (Haven container).

Basic or other authentication can be added to limit access to authenticated users. See the Traefik v2 documentation for more.

Once you get everything (including HTTPS reverse proxy) in order, you may add `-d` to `docker compose up` run Haven in the background.

### Internal (LAN) IP with internal hostname or localhost

You can use localhost or some LAN host. For TLS (required) you need a CA-issued or self-signed TLS certificate with DNS resolution. You can use non-trusted, but you can also check the documentation for your OS on how to add this TLS to your OS and browser.

From the [Caddy documentation](https://caddyserver.com/docs/running#docker-compose), here's how we can use `docker compose cp` to copy Caddy CA-signed certificate to your Ubuntu host. See the link for the browser part.

```sh
docker compose cp \
    caddy:/data/caddy/pki/authorities/local/root.crt \
    /usr/local/share/ca-certificates/root.crt \
  && sudo update-ca-certificates
```

Or you could create them using your existing CA and copy them to the container. Either way, that's out of scope so let's move on.

You may use docker-compose-localhost.yml and Caddyfile from the repo root for this:

```yaml
version: "3.3"
services:
  reverse-proxy:
    image: caddy
    container_name: "caddy"
    restart: unless-stopped
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - "./caddy_data:/data"
      - "./caddy_config:/config"
      - "./Caddyfile:/etc/caddy/Caddyfile"
  haven-web:
    image: ghcr.io/armchairancap/haven:latest
    # image: ghcr.io/armchairancap/haven-arm64:latest # use this for ARM64
    container_name: "node-server"
    entrypoint: ["npm", "run", "start"]
    ports:
      - "3000:3000"
```

This Caddy example will make Haven accessible from `https://localhost` (Caddy proxy).

```sh
docker-compose -f docker-compose-localhost.yml up
```

You may see something like this:

![Running Haven container on LAN](./images/running-container-lan.png)

As the TLS certificate is signed by a Caddy CA generated on the fly, it will show as insecure unless you import both the Caddy CA file(s) and the certificate to make them trusted. See the Caddy documentation and community information for more. You don't *need* a valid & trusted TLS certificate for localhost, but on LAN hosts it would be better to have one.

Once you get everything (including HTTPS reverse proxy) in order, you may add `-d` to the Docker command to run in the background.

### Haven as Hiden Service on .onion network

Before you waste hours on this, remember that Tor browser cannot use Haven/Speakeasy because WASM isn't built in. *If* you're thinking about using Tor, forget about it. But you can use Haven on .onion from another browser connected through a Socks5 proxy, for example.

For .onion we'd likely use a self-signed CA and host TLS certificate, but there's nothing wrong with using just HTTP for `.onion` sites.

Maybe a self-generated TLS could contain some data that would prove it was created by a trusted person, but otherwise there's no difference between using HTTPS with a self-signed TLS certificate and HTTPS on Tor.

This hasn't been tested, but you could reuse the example for LAN, just change Caddyfile to bind all interfaces including your .onion name, and do not open Internet or LAN firewall ports since access would happen over .onion network.

In Tor configuration you may need to set HiddenServicePort (:80 and/or :443) to expose it on .onion address and tune other options.

## Version and other container information

Images tagged `:latest` are built from the upstream repository's `main` branch. Other images may be available as well - for example images built from the branch `dev` would be tagged `:dev`.

- x86_64: `haven:latest`
- ARM64 build: `haven-arm64:latest`

My Docker images may get out of date, so it is recommended to build your own version (which comes from [here](https://git.xx.network/elixxir/speakeasy-web)) for proper production use. There's a working Dockerfile in the source code repository. Or see the older Docker example I used before.

The upstream repository may have some vulnerabilities which I haven't attempted to fix (why, because I could inadvertently introduce new ones). Haven executes on the client and it is read-only on the server, so the risk of NPM package vulnerabilities should be extremely low - especially if you run own instance.

What I did modify is packages*.json and node.config.json to decrease the size of my Haven container image compared to what you'd get from Dockerfile from the source code repository. I also ran `npm audit fix` to auto-fix some vulnerabilities that NPM can fix on its own, although that probably doesn't help in any way.

## License

- For Speakeasy / Haven, please refer to upstream license
- This repo uses the MIT License
