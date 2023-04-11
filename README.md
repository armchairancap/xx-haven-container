- [Speakeasy container image](#speakeasy-container-image)
  - [About Speakeasy](#about-speakeasy)
    - [Speakeasy Web server](#speakeasy-web-server)
  - [Run or build \& run Speakeasy](#run-or-build--run-speakeasy)
    - [Run](#run)
    - [Build and run](#build-and-run)
  - [Deploy HTTPS reverse proxy](#deploy-https-reverse-proxy)
  - [Version information](#version-information)

# Speakeasy container image

## About Speakeasy

[Speakeasy](https://www.speakeasy.tech) is a privacy-first Web client for xx Network.

It uses WASM and xxDK to access random gateways on the cMix network. It provides unique online identities, quantum-secure encrypted messaging and other features. See the Web site for more.

### Speakeasy Web server

A Web server is required to download the Speakeasy application code. A site running it - such as [https://www.speakeasy.tech](https://www.speakeasy.tech) - may collect client IP addresses (which merely identifies the address as a Speakeasy user) or, if compromised, even serve malicious code (this is unlikely, but not impossible, to happen on the official Speakeasy site).

The Speakeasy Web server is not involved in forwarding or encrypting of Speakeasy data: that happens exclusively between the Web client and the xx Network gateways to which the client (browser) connects directly. 

Because of that a Speakeasy server running clean code cannot determine the content of messages, or even parties who exchange them. Why? 

Because chat participants can access any Speakeasy Web server (it doesn't have to be the same server) and even if they didn't (if they used the same Speakeasy Web server, that is), it would be impossible to detect and prove these clients are exchanging messages. Remember - Speakeasy messages aren't routed via the Web server. But, two clients accessing a Speakeasy Web server at the same tells us they may be communicating, so there's always some advantage to running your server.

In light of that, the main objectives of creating this Speakeasy container image are:

- Make it easy to run own Speakeasy server built from the source code
- Removes the risk of the server operator recording your IP address
- Removes the risk of using malicious application code
- Make Speakeasy Web app easily accessible from internal or external portals

Typical deployment scenarios:

- Small (1GiB) cloud VM with Docker running Speakeasy container, reverse-proxied by Cloudflare or another container (NGINX, Traefik, Caddy, etc.) on the same VM
- Speakeasy and HTTPS proxy container on your desktop, notebook or home server

Setting up a reverse HTTPS proxy is out of scope as it requires no Speakeasy-specific steps: just forward HTTPS to whatever port Speakeasy container is exposed at.

## Run or build & run Speakeasy

Note: use `run -d -p` to run a container in the background.

Foreground mode (below) can be exited with CTRL+C.

### Run

It is recommended to build your own image from this repository's Dockerfile (see further below). If you just want to test it, you may use my [Docker Hub image](https://hub.docker.com/r/armchairancap/xx-speakeasy-container/tags). Use a port available on your system, whether it's 8080 or other.

```sh
docker run -it --rm -p 0.0.0.0:8080:80 --name speakeasy docker.io/armchairancap/xx-speakeasy-container:latest npm run start

```

Using this command should start Speakeasy container and expose its service at http://localhost:8080. You still need a reverse HTTPS proxy in front of it in order to use it!

### Build and run

If port 8080 on your Docker host is not free, change the port with something like `-p 31080:80` or `-p 127.0.0.2:80:80` (localhost example) or try one of other Docker tricks from the Internet.

Build and run at port 8080:

```sh
docker build -t speakeasy:latest .
docker run -it --rm -p 0.0.0.0:8080:80 --name speakeasy speakeasy:latest npm run start

```

Now you should be able to see the Speakeasy Web server's home page when you visit http://localhost:8080. You still need a reverse HTTPS proxy in front of it in order to use it!

## Deploy HTTPS reverse proxy

Without HTTPS in front of Speakeasy you will see the home page, but Speakeasy will not work for messaging. You need to access Speakeasy through HTTPS.

There is nothing Speakeasy-specific about this, just remember to forward port on your your HTTPS proxy to whatever port you chose here (e.g. 8080).

Examples:

- [Caddy automatic HTTPS with Let's Encrypt](https://caddyserver.com/docs/automatic-https)
- [Cloudflare TLS reverse proxy](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes)

## Version information

The Docker Hub images are built for `amd64` and `arm64` and downloading `:latest` gets the right architecture for your system (whether it's ARM64 or x86_64).

The Docker Hub images may not be the latest version, so it is recommended to build your own version (which comes from [here](https://git.xx.network/elixxir/speakeasy-web)) for proper production use.
