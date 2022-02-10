# Cluster CRDs

Since Terraform builds a dependency graph during the plan phase and the Kubernetes provider compares requested resources against cluster CRDs, we need to have them applied in a separate context.
