## SSH Connection to a PC in the Local Network

Let's look at the steps to enable SSH access to a PC in a local network:

1) Generate a public/private key pair using  
   `ssh-keygen -t rsa -b 4096 -C "comment"`  
   — it's convenient to use an email or some code word as the comment for reference.

2) Transfer the RSA key to the target PC using  
   `ssh-copy-id remote_user@remote_ip`.  
   When prompted, answer `yes` and enter the password for the remote user.

3) Now you can connect using the command  
   `ssh remote_user@remote_ip`

> [!NOTE]  
> Sometimes aliases might not work when connecting via SSH.  
> To activate them (and also enable terminal highlighting), run:  
> `source .bashrc`

## File Transfer via SSH

You can transfer files via SSH once keys are set up using the `scp` command:

- To transfer a single file:  
  `scp path/to/file remote_user@remote_ip:/home/user/path/`

- To transfer a directory with all contents recursively, use the `-r` flag:  
  `scp -r path/to/folder remote_user@remote_ip:/home/user/path/`

- You can also copy in reverse — from the remote PC to your current one —  
  by swapping the local and remote paths.

> When copying a file with the same name to the same directory,  
> the old file will be overwritten by the new one.
