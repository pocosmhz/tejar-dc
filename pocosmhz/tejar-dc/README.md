# Tejar DC
This part of the IaC tree takes care only about infrastructure. That is, VMs, HA elements, raw storage and such.

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