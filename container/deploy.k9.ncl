K9!
# SPDX-License-Identifier: MPL-2.0
# deploy.k9.ncl — gossamer deployment component (Hunt level)
#
# k9-svc deployment component, K9 contract v1.0.0 (D173). Shipped as
# deploy.k9.ncl.in because a template is not a component: `just repo-init`
# fills PROJECT_NAME and VERSION, `just container-init` fills SERVICE_NAME,
# PORT and REGISTRY, and once no brace token is left `just container-init`
# renders it to build/container/stapeln/deploy.k9.ncl.
#
# WARNING: this component executes shell commands. It is 'Hunt, so a host
# runs it only with all five Hunt preconditions met, a verified signature
# among them. The signature block below is a claim until the owner signs the
# rendered file; until then the validator reports it 'Present_Unverified
# (K9-C001) and Hunt stays unauthorised.
#
# Usage (on the rendered file):
#   k9-validate.sh --strict --layer L2 build/container/stapeln/deploy.k9.ncl
#   k9-svc validate build/container/stapeln/deploy.k9.ncl
#   k9-svc deploy build/container/stapeln/deploy.k9.ncl --env production

{
  pedigree = {
    schema_version = "1.0.0",
    component_type = "deployment",

    metadata = {
      name = "gossamer-deploy",
      version = "0.3.1",
      description = "gossamer deployment component (Hunt level)",
    },

    # Target environment (extension field; contract §5.5).
    target = {
      os = 'Linux,
      is_edge = false,
      requires_podman = true,
      min_memory_mb = 256,
    },

    security = {
      leash = 'Hunt,
      trust_level = "controlled-execution",
      allow_network = true,
      allow_filesystem_write = true,
      allow_subprocess = true,
      signature_required = true,
      # Default-deny: every flag above is paid for here (contract §8.4), plus
      # the deploy and rollback actions the scripts below perform.
      capabilities = [
        "net.fetch",
        "fs.write",
        "process.spawn",
        "container.run",
        "deploy.apply",
        "rollback.apply",
      ],
    },

    warnings = [
      "This is a Hunt-level component: it executes shell commands and changes the system.",
      "Review the deployment scripts before running it.",
      "A signature block being present is not a signature being verified.",
      "Authorise Hunt explicitly: k9-svc authorize build/container/stapeln/deploy.k9.ncl",
    ],

    side_effects = [
      "spawns build/container/stapeln/ct-build.sh, which builds the image and packs and signs a .ctp bundle beside it",
      "pulls and pushes ghcr.io/metadatastician/gossamer images",
      "starts, updates and stops the gossamer stack with selur-compose, else podman compose over build/container/compose.yaml",
      "publishes the service on port 8080",
    ],

    # Ed25519, presence only (K9-S009). The signing step adds payload_hash
    # and signature to the rendered file; verification is K9-C001 (L3).
    signature = {
      algorithm = "Ed25519",
      key_id = "primary",
    },
  },

  # Deployment configuration
  deployment = {
    # Target environments (dev / staging / production)
    environments = {
      dev = {
        replicas = 1,
        memory = "256Mi",
        cpu = "100m",
        image_tag = "dev",
      },
      staging = {
        replicas = 2,
        memory = "512Mi",
        cpu = "250m",
        image_tag = "staging",
      },
      production = {
        replicas = 3,
        memory = "1Gi",
        cpu = "500m",
        image_tag = "latest",
      },
    },

    # Container configuration
    container = {
      image = "ghcr.io/metadatastician/gossamer",
      port = 8080,
      health_check = "/health",
      readiness_check = "/ready",
    },

    # Deployment strategy
    strategy = {
      type = "rolling",
      max_surge = 1,
      max_unavailable = 0,
    },
  },

  # Deployment scripts (executed at Hunt level)
  scripts = {
    # Pre-deployment validation
    pre_deploy = m%"
#!/bin/sh
set -eu
echo "K9: Pre-deployment validation for gossamer..."
cd build/container/stapeln
if command -v selur-compose >/dev/null 2>&1; then
  selur-compose verify
else
  podman compose --file ../compose.yaml config
fi
echo "K9: Validation passed."
"%,

    # Deployment script
    deploy = m%"
#!/bin/sh
set -eu
ENV="${1:-dev}"
echo "K9: Deploying gossamer to $ENV environment..."
cd build/container/stapeln
./ct-build.sh
if command -v selur-compose >/dev/null 2>&1; then
  selur-compose up --detach
else
  podman compose --file ../compose.yaml up --detach
fi
echo "K9: Deployment to $ENV complete."
"%,

    # Rollback script
    rollback = m%"
#!/bin/sh
set -eu
echo "K9: Rolling back gossamer deployment..."
cd build/container/stapeln
if command -v selur-compose >/dev/null 2>&1; then
  selur-compose down
else
  podman compose --file ../compose.yaml down
fi
echo "K9: Rollback complete."
"%,
  },

  # Just recipes: an execution surface, which is why the leash is 'Hunt
  # (K9-S011).
  recipes = {
    install = {
      description = "Build the container image",
      commands = ["just container-build"],
    },
    validate = {
      description = "Verify the compose configuration",
      commands = ["just container-verify"],
    },
    deploy = {
      description = "Start the container stack",
      commands = ["just container-up"],
    },
    migrate = {
      description = "Rebuild the image and restart the stack",
      commands = ["just container-build", "just container-up"],
    },
  },
}
