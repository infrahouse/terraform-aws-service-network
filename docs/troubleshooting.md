# Troubleshooting

Common issues when deploying the module and how to resolve them.

## `replication_region must be different from the current region`

```text
Error: Resource precondition failed

  replication_region must be different from the current region
  (us-west-2). Got: us-west-2
```

**Cause:** Cross-region replication of the flow logs bucket requires a destination in a
different region than the one the module is deployed in.

**Fix:** Set `replication_region` to any other AWS region, e.g. `us-east-1`.

## `expected length of bucket_prefix to be in the range (0 - 37)`

```text
Error: expected length of bucket_prefix to be in the range (0 - 37),
got vpc-flow-logs-service-network-replica-
```

**Cause:** In module versions 5.0.0–5.0.1, a `service_name` longer than 14 characters
produced a replica bucket prefix that exceeded the AWS limit
([#46](https://github.com/infrahouse/terraform-aws-service-network/issues/46)).

**Fix:** Upgrade to module version 5.0.2 or later, or shorten `service_name` to
14 characters or fewer.

## `Each subnet must specify either availability_zone or availability-zone`

**Cause:** A subnet object in the `subnets` list is missing an availability zone.

**Fix:** Add `availability_zone` to every subnet. The dash-spelled `availability-zone`
attribute is deprecated but still accepted for backward compatibility.

## `no matching EC2 VPC found` for the management VPC

```text
Error: no matching EC2 VPC found

  with module.website.data.aws_vpc.management_vpc[0]
```

**Cause:** A service network looks up the management VPC by `management_cidr_block`. The
lookup fails when the management network does not exist yet, was created with a different
CIDR, or lives in a different account or region.

**Fix:** Deploy the management network first (in the same account and region), and make
sure `management_cidr_block` exactly matches its `vpc_cidr_block`.

## `multiple EC2 VPCs matched`

**Cause:** More than one VPC in the account/region has the CIDR block given in
`management_cidr_block`, so the module cannot tell which one is the hub.

**Fix:** Use a unique CIDR block for the management VPC, or remove the duplicate VPC.

## `terraform destroy` fails with `BucketNotEmpty`

```text
Error: deleting S3 Bucket (vpc-flow-logs-...): BucketNotEmpty
```

**Cause:** The flow logs buckets accumulate log objects (and object versions), which S3
refuses to delete implicitly.

**Fix:** Set `flow_logs_force_destroy = true` and apply before destroying. Intended for
test and development environments; for production, keep the logs and let lifecycle rules
expire them.

## Instances in a private subnet cannot reach the internet

**Cause:** Private subnets only get an internet route when `forward_to` points at a
subnet with a NAT Gateway. Also note that a NAT Gateway must live in a *public* subnet
(`map_public_ip_on_launch = true`) — a NAT in a private subnet has no path to the
Internet Gateway.

**Fix:** Set `create_nat = true` on a public subnet and `forward_to = "<that subnet's
cidr>"` on each private subnet that needs outbound access.

## Instances cannot communicate at all

**Cause:** By default (`restrict_all_traffic = true`) the VPC's default security group
denies all traffic, per compliance requirements.

**Fix:** Attach purpose-built security groups to your instances (recommended), or set
`restrict_all_traffic = false` to allow all traffic within the VPC CIDR.

## `Warning: Deprecated attribute` for `data.aws_region.current.name`

**Cause:** AWS provider 6.x deprecated the `name` attribute of the `aws_region` data
source in favor of `region`. Module versions up to 5.0.1 still reference `name`.

**Fix:** The warning is harmless. Upgrade to module version 5.0.2 or later to
silence it.
