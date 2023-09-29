# Doomlabs
Another long-running infrastructure project of mine,
maybe this time it's gonna turn into something productive.

We'll see... Anyways, if you stumbled upon this, this is gonna
be a rather huge mono-repo (maybe I'll split it up later) containing
the infrastructure, a few services & tools.

I enjoy using [Terraform](https://www.terraform.io/) and 
[Docker](https://www.docker.com/) for infrastructure, so that's the stack
here.

## Services
### Nginx
I need something for reverse proxying, and the easy option is Apache, but
since it's a pain to configure (given that it's an XML'ish config) I will
use [Nginx](https://www.nginx.com/) instead.

The idea is that it's extensible, so I can adjust it to my needs with the
power of Lua, should that ever be necessary (I hope not q.q).

The integration with the later mentioned LDAP can be found
[here](https://github.com/kvspb/nginx-auth-ldap).

### TLS
This is gonna be a world of pain, but we're gonna do it, so no use complaining:
I need to get a TLS certificate for the server, and I'm gonna use the
[Certbot Cloudflare Container](https://hub.docker.com/r/certbot/dns-cloudflare) 
to streamline the process.

### LDAP-Authentication
Once again, I am trying to build something that: **scales**, is **secure**
and easy to connect with other services, for that I require a shared
authentication system.
Most services allow you to connect with LDAP, so that's what I'm going
to attempt to implement.
(Never tried, but we never know, right?)

Additionally Docker has a neat container for LDAP:
[osixia/openldap](https://hub.docker.com/r/osixia/openldap/),
which I will use for exactly that. 
([Medium-Guide](https://medium.com/rahasak/deploy-ldap-directory-service-with-openldap-docker-8d9f438f1216))

To verify that everything's working as it's supposed to, this seems neat:
[DigitalOcean LDAP-Utils](https://www.digitalocean.com/community/tutorials/how-to-manage-and-use-ldap-servers-with-openldap-utilities)

Another interesting note regarding authentication and security is the following:
You can have encrypted git secrets using 
[git-crypt](https://daily.dev/blog/managing-your-secrets-in-git), which seems
like that path I'll take as soon as I got GPG set-up on my dev devices and the
server.

### Git Server
My resources are quite limited (feel free to donate), so, for now I'll
run a [dockerized](https://docs.gitea.io/en-us/install-with-docker/) [Gitea](https://gitea.io/) instance.
With [plugins and all](https://gitea.com/gitea/awesome-gitea), it should 
be able to handle most of my needs, namely CI/CD, issue tracking, stats 
for nerds and braggers, etc...
- [ ] Gitea Instance
- [ ] [Gitea LDAP Auth](https://docs.gitea.io/en-us/authentication/)
- [ ] [Gitea CI/CD](https://github.com/agola-io/agola)
- [ ] [Gitea Monitoring](https://github.com/go-gitea/gitea/tree/main/contrib/gitea-monitoring-mixin)

### Trilium Sync Server
The great world of Open Source, has created a great tool for note-taking:
[Trilium](https://github.com/zadam/trilium).
These notes can also be sync'ed across devices using a sync-server.

### Monitoring
I plan on adding some monitoring to the server, so I can keep track of things.
This should be admin(myself)-only and will be achieved with
[Grafana](https://grafana.com/) and [Prometheus](https://prometheus.io/).

## Doomlabs Service Paths
- [ ] [Personal Introduction](https://doomlabs.org/) (Public)
- [ ] [Gitea](https://git.doomlabs.org/) (Auth-Only?)
- [ ] [Komga](https://komga.doomlabs.org/) (Auth-Only?)
- [ ] [Trilium](https://trilium.doomlabs.org/) (Auth-Only?)
- [ ] [Grafana](https://metrics.doomlabs.org/) (Admin-Only?)

The '?' implies that there *may* be a better way to achieve the desired
effect, such as through application-level authentication (instead
of using a reverse proxy).
