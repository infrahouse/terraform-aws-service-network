# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## First Steps

**Your first tool call in this repository MUST be reading
.claude/CODING_STANDARD.md. Do not read any other files, search, or take any
actions until you have read it.** This contains InfraHouse's comprehensive
coding standards for Terraform, Python, and general formatting rules.

## Common Commands

```bash
make bootstrap      # Install Python dependencies (pip, setuptools, requirements.txt)
make test           # Run full test suite: pytest -xvvs tests
make format         # Format all code: terraform fmt -recursive + black tests
make lint           # Check Terraform formatting: terraform fmt --check -recursive
```

Tests are pytest-based integration tests that deploy real AWS infrastructure.
They use `pytest-infrahouse` fixtures and `infrahouse-core` helpers. Tests are
parametrized across AWS provider versions (~5.11 and ~6.0). Expect long run
times (CI timeout is 120 minutes).

Run a single test scenario:
```bash
pytest -xvvs tests/test_one_vpc.py -k "aws-5-management_cidr_block0"
```

## Architecture

This module creates isolated AWS VPC "service networks" with an optional
management network peering topology.

**Core concept:** A management network is detected when
`management_cidr_block == vpc_cidr_block`. Service networks (where these
differ) automatically peer with the management VPC, creating a hub-and-spoke
topology where service networks are isolated from each other but can
communicate through the management network.

**Key Terraform files:**
- `vpc.tf` - VPC resource
- `subnets.tf` - Dynamic subnet creation via `for_each` over the `subnets`
  variable
- `routing.tf` - Per-subnet route tables; adds peering routes for
  non-management networks
- `gateways.tf` - Internet Gateway (always) and optional per-subnet NAT
  Gateways with EIPs
- `peering.tf` - VPC peering connections to management network (conditional)
- `vpc_flow_logs.tf` - S3-based VPC Flow Logs with bucket policies and
  lifecycle rules
- `vpc_endpoint.tf` - S3 gateway endpoint
- `security_groups.tf` - Default security group (restricted by default via
  `restrict_all_traffic`)
- `locals.tf` - Derived subnet lists (public, private, NAT-enabled) extracted
  from the `subnets` variable

**Subnet configuration** is a list of objects with per-subnet control over
CIDR, AZ, public IP mapping, NAT gateway creation, and traffic forwarding
(`forward_to` routes to a specific NAT gateway in another subnet).

**Testing:** Integration tests in `tests/test_one_vpc.py` deploy the module
via configurations in `test_data/service_network/`, create EC2 instances in
each subnet, and verify connectivity. The `conftest.py` helper generates
`terraform.tfvars` dynamically.

## Version Management

Version is tracked in `.bumpversion.cfg` and updated in `README.md` and
`locals.tf`. Releases are triggered by pushing version tags (`v*`).
