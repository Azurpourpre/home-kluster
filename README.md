# Home-Kluster

## What is it ?

Home-kluster is my personnal homelab ! Lab architecture is [here](doc/architecture.drawio). I wanted to make everything as reproductible (with my infrastructure) and secure as possible. So of course this is adherent to my dns (pi-hole) and my infrastructure topology.

Home-kluster takes the form of a talm chart, to configure talos linux, and uses Fluxcd to install everything afterwards

## Deployment

First, generate missing files *(cluster secrets)*
``` bash
talm init -p generic
```
and add pihole secrets in ```misc/secrets/pihole.yaml```
``` yaml
apiVersion: v1
kind: Secret
metadata:
  name: pihole-password
  namespace: external-dns
data:
  EXTERNAL_DNS_PIHOLE_PASSWORD: <your pihole password>
```
Also, you need to retrieve the talos schematic id
``` bash
curl -X POST --data-binary @talos-schematic.yaml https://factory.talos.dev/schematics
```
Now you boot Talos Linux on all your machines. You will have to use the schematic ID previously generated to have the Talos extensions required. Also, you have to manually configure the network settings for every machine.

Once all your machines are up, generate the nodes configuration. For each machine, you have set up a ip and a name, and you have to choose a role (controleplane or worker)
``` bash
talm -n <ip> -e <ip> template -t templates/<role> -i > nodes/<node name>.yaml
talm apply -f nodes/<node name>.yaml -i
```
Then, finish initialization
``` bash
talosctl --talosconfig=./talosconfig config endpoints <ip control plane>
talosctl bootstrap --nodes <ip control plane> --talosconfig=./talosconfig
helm install cilium oci://quay.io/cilium/charts/cilium --version 1.18.0 --namespace kube-system -f https://raw.githubusercontent.com/Azurpourpre/home-kluster/refs/heads/master/misc/cilium/values.yaml
```

## Init

Initialize Flux PGP Private key by applying app-secrets/hk-sops.priv.yaml

Initialize Openbao via portforwarding, and configure it with OpenTofu :
```
cd misc/openbao/state
tofu init
tofu apply
```

Initialize Gitea Runner by providing secret
```
kubectl create secret generic -n gitea-runner gitea-actions-token --from-literal action-token=<token>
```

## Contributing