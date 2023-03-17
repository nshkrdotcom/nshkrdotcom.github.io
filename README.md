# README for NSHkr.com
# Hugo site with mainroad theme

## INSTALLATION

## set up your ~/.ssh/config to support different ssh keys for multiple github accts
 example:

```
#main
Host github.com
	HostName github.com
	User git
	IdentityFile ~/.ssh/id_rsa
	IdentitiesOnly yes

#nshkr account
Host github-nshkrdotcom
	HostName github.com
	User git
	IdentityFile ~/.ssh/id_rsa_nshkrdotcom
	IdentitiesOnly yes

Host ec2
	HostName ec2-192-168-1-1.us-west-1.compute.amazonaws.com
	User ubuntu
	IdentityFile ~/.ssh/2019-16inch-MBP.pem

```

etc set up that key on your github for this repo so u can clone/commit

## CLONE IT with the above specialized URL for the alternate github host:

```
git clone --recurse-submodules -j8 git@github-nshkrdotcom:nshkrdotcom/nshkrdotcom.github.io.git
```
