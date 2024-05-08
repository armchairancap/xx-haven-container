## Example for Haven with Tor Hidden Service

See [this post](https://armchairancap.github.io/blog/2024/05/08/can-securedrop-reinvent-the-wheel-probably-not) for more.

### tldr

Clone this repo, enter this `tor` directory and put file(s) that you want to share over Tor in `./tor-docs/`. If you want extra security on Tor, encrypt the file before copying it to `./tor-docs/`. 

- tor-config/ - Tor Hidden Service configuration file (for NGINX)
- tor-docs/  - put your file(s) shared over Hidden Service (file.txt, etc.) to this directory
- tor-service/ - Tor identity will be stored here. Delete it every time after running if you don't want to retain or leave it here

Then run `docker compose up`. You may stop it with `CTRL+C`. Run with `-d` to run Docker in background and stop with `docker compose stop` (use `start` to restart with same Onion address).

Haven will be at https://localhost:443, while Hidden Service will be accessible at the address contained in `./tor-service/hostname`.

Use Haven to inform the other party where to get the file. Your Haven identity is not stored anywhere, so you need to back it up (export to JSON stored in a secure place) in order to reuse it.

### Credit

- https://github.com/ha1fdan/hidden-service-docker for Hidden Service example
