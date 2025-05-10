# tejar-dc
Tejar data center IaC repository.

## The data center

Please be welcome to my humble data center. See how it is built here:
- [Part I](https://manuelmc.pocosmhz.org/2025/04/13/proxmox-home-cluster-i.html)
- [Part II](https://manuelmc.pocosmhz.org/2025/04/15/proxmox-home-cluster-ii.html)

## The tools
The foundation of Tejar DC is [Proxmox VE](https://www.proxmox.com/en/). The setup process is deailed in the section above.

On top of that, this IaC repository will take care of all the resources that will make a good use of the hypervisor, through the following tools:

- [tenv](https://tofuutils.github.io/tenv/)
- [OpenTofu](https://opentofu.org/)
- [cloud-init](https://cloud-init.io/)
