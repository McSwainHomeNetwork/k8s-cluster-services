# k8s-cluster-services

A set of Terraform configurations to deploy services that typical kubernetes cluster clients might like to utilize. The target cluster in this configuration is a deployment of <https://github.com/McSwainHomeNetwork/proxmox-k3s-server>

Note: Cert-manager requires CRDs to be installed prior to using this. This is because a Terraform plan will attempt to check CRDs against local manifests, and we use ClusterIssuer.

This list is comprehensive as of writing, but will drift and shall serve as an example of some services that might fit in this repo:

- NGINX Ingress Controller <https://kubernetes.github.io/ingress-nginx/>
- PostgreSQL <https://www.postgresql.org/>
- MariaDB <https://mariadb.org/>
- democratic-csi <https://github.com/democratic-csi/democratic-csi> + NFS and iSCSI StorageClasses with NFS being the default.
- backups (includes whole-cluster flat yaml backups, etcd backups, Velero <https://velero.io/>, etc)
- Prometheus <https://prometheus.io/>
- Grafana <https://grafana.com/> + Loki <https://grafana.com/oss/loki/>
- node_exporter <https://github.com/prometheus/node_exporter>
- Keycloak <https://www.keycloak.org/> + oauth2-proxy <https://github.com/oauth2-proxy/oauth2-proxy>
- cert-manager <https://cert-manager.io/docs/> + a DDNS and ACME HTTP challenge ClusterIssuers
- MetalLB <https://metallb.universe.tf/> in ARP mode as the hosting network is VLAN-ed
- ses-email-service <https://github.com/USA-RedDragon/ses-email-service>
- external service mapping (basically, add accessible names to services external to the cluster that may be shared via an `Endpoints` object, a Service, and an Ingress)

Each deployment herein should be completely production-ready and include a mechanism for metrics collection where available and backups where persistent data is stored, including the configuration (if configuration is in a ConfigMap rather than a PVC, this is sufficient to be collected by flat yaml backups of the cluster). Internal services may be exposed via the main load balancer, as long as they are filtered through oauth2-proxy. PodSecurityPolicies and NetworkPolicies should be used where applicable.
