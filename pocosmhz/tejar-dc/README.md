# Tejar DC
This part of the IaC tree takes care only about infrastructure. That is, VMs, HA elements, raw storage and such.

## Provisioning Proxmox assets
In order to use the [Proxmox provider](https://registry.terraform.io/providers/bpg/proxmox) for Terraform, we need a set of credentials.

Instead of using the default superuser account, we're going to create a `terraform` account and use it for all purposes here.

1. Log in to one of the Proxmox cluster nodes and create a new role:
    ```Shell
    # pveum role add TerraformProv -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
    ```
2. Now create a new user, assign a password and the role we've created:
    ```Shell
    # pveum user add terraform-prov@pve --password XX12345YY
    # pveum aclmod / -user terraform-prov@pve -role TerraformProv
    ```

However, that does not work well with SSH for the time being.

You can either use `root` credentials or do the following (not completely tested, you're on your own):

1. Create a UNIX user on all Proxmox nodes.
2. Assign a password
3. Create a PAM user with the same name, through `pveum` and assign it
4. Create a UNIX user group and add the new user to that group.
5. Install `sudo` and provide appropriate permissions.

You might get more information from [this Reddit post](https://www.reddit.com/r/Proxmox/comments/16nwvgh/what_is_the_proper_way_to_create_a_new_proxmox/).

From here on, YMMV. Please let me know if you succeed.

## Jump host
As this is intended for a domestic lab, only one public IP address is needed for all the tasks.

The jump host / bastion host uses [sshpiper](https://github.com/tg123/sshpiper) to allow access to multiple hosts through a single service port.

It is planned in a way that you only need to fill in the following variable:

```HCL
admin_users = [
  {
    name    = "johnd"
    gecos   = "John Doe"
    ssh_key = "ssh-rsa AAAABTHISISYOURKEYBLABLABLABLABLA johnd@yourhost"
  },
  {
    name    = "janed"
    gecos   = "Jane Doe"
    ssh_key = "ssh-rsa AAAABTHISISOTHERKEYBLABLABLABLABLA janed@yourhost"
  }
]
```

and after that, every time you add a new Kubernetes host or other VM, the jump host will automatically be regenerated.

It allows you to access every host by using the user name and hostname you want, with your SSH key, this way:

```Shell
$ ssh-add
Identity added: /home/johnd/.ssh/id_rsa (/home/johnd/.ssh/id_rsa)
$ ssh -o UpdateHostKeys=no -l root.onprem01cp01 yourhomelab.example.com
Linux onprem01cp01 6.1.0-37-cloud-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.140-1 (2025-05-22) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Fri May 30 10:13:13 2025 from 192.168.18.140
root@onprem01cp01:~# 
```

## Kubernetes clusters
The Kubernetes clusters orchestrated here implement the following base features:

- Kubernetes version of choice. Vanilla Kubernetes installation.
- External URL for managing Kubernetes from outside home lab.
- CNI plugin of choice. Currently, only latest version of Calico is available.