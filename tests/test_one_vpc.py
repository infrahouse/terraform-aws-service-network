from pprint import pformat

import pytest
from infrahouse_toolkit.terraform import terraform_apply

from tests.conftest import create_tf_conf, TRACE_TERRAFORM, DESTROY_AFTER


@pytest.mark.parametrize(
    ", ".join(
        [
            "region",
            "management_cidr_block",
            "vpc_cidr_block",
            "subnets",
            "expected_nat_gateways_count",
            "expected_subnet_all_count",
            "expected_subnet_public_count",
            "expected_subnet_private_count",
            "restrict_all_traffic",
        ]
    ),
    [
        # One VPC with no subnets
        (
            "us-east-1",
            "10.0.0.0/16",
            "10.0.0.0/16",
            "[]",
            0,  # expected_nat_gateways_count
            0,  # expected_subnet_all_count
            0,  # expected_subnet_public_count
            0,  # expected_subnet_private_count
            False,  # restrict_all_traffic
        ),
        # One VPC with no subnets, restrict all traffic
        (
            "us-east-1",
            "10.0.0.0/16",
            "10.0.0.0/16",
            "[]",
            0,  # expected_nat_gateways_count
            0,  # expected_subnet_all_count
            0,  # expected_subnet_public_count
            0,  # expected_subnet_private_count
            True,  # restrict_all_traffic
        ),
        # One VPC with one subnet
        (
            "us-east-1",
            "192.168.0.0/24",
            "192.168.0.0/24",
            """[
                {
                    cidr                    = "192.168.0.0/24"
                    availability-zone       = "us-east-1a"
                    map_public_ip_on_launch = true
                    create_nat              = false
                    forward_to              = null
                }
            ]
            """,
            0,  # expected_nat_gateways_count
            1,  # expected_subnet_all_count
            1,  # expected_subnet_public_count
            0,  # expected_subnet_private_count
            False,  # restrict_all_traffic
        ),
        # One VPC with three subnets
        (
            "us-east-1",
            "10.1.0.0/16",
            "10.1.0.0/16",
            """[
                {
                    cidr                    = "10.1.0.0/24"
                    availability-zone       = "us-east-1a"
                    map_public_ip_on_launch = true
                    create_nat              = true
                    forward_to              = null
                },
                {
                    cidr                    = "10.1.1.0/24"
                    availability-zone       = "us-east-1b"
                    map_public_ip_on_launch = false
                    create_nat              = false
                    forward_to              = "10.1.0.0/24"
                },
                {
                    cidr                    = "10.1.2.0/24"
                    availability-zone       = "us-east-1c"
                    map_public_ip_on_launch = false
                    create_nat              = false
                    forward_to              = "10.1.0.0/24"
                }
            ]
            """,
            1,  # expected_nat_gateways_count
            3,  # expected_subnet_all_count
            1,  # expected_subnet_public_count
            2,  # expected_subnet_private_count
            False,  # restrict_all_traffic
        ),
    ],
)
def test_service_network(
    ec2_client_map,
    region,
    management_cidr_block,
    vpc_cidr_block,
    subnets,
    expected_nat_gateways_count,
    expected_subnet_all_count,
    expected_subnet_public_count,
    expected_subnet_private_count,
    restrict_all_traffic,
):
    ec2_client = ec2_client_map[region]

    tf_dir = "test_data/service_network"
    with create_tf_conf(
        tf_dir=tf_dir,
        region=region,
        management_cidr_block=management_cidr_block,
        vpc_cidr_block=vpc_cidr_block,
        subnets=subnets,
        restrict_all_traffic=restrict_all_traffic,
    ):
        with terraform_apply(
            tf_dir,
            json_output=True,
            var_file="terraform.tfvars",
            enable_trace=TRACE_TERRAFORM,
            destroy_after=DESTROY_AFTER,
        ) as tf_out:
            response = ec2_client.describe_vpcs(
                Filters=[
                    {"Name": "state", "Values": ["available"]},
                    {"Name": "cidr", "Values": [vpc_cidr_block]},
                ],
            )
            assert (
                len(response["Vpcs"]) == 1
            ), "Unexpected number of VPCs: %s" % pformat(response, indent=4)
            vpc_id = response["Vpcs"][0]["VpcId"]
            assert (
                tf_out["vpc_id"]["value"] == vpc_id
            ), "Unexpected terraform output: %s" % pformat(tf_out, indent=4)

            # Check Internet gateway is created
            response = ec2_client.describe_internet_gateways(
                Filters=[
                    {"Name": "attachment.vpc-id", "Values": [vpc_id]},
                    {"Name": "attachment.state", "Values": ["available"]},
                ],
            )
            assert len(response["InternetGateways"]) == 1

            # Check NAT gateway
            response = ec2_client.describe_nat_gateways(
                Filters=[{"Name": "state", "Values": ["available"]}],
            )
            assert len(response["NatGateways"]) == expected_nat_gateways_count

            # Check Elastic IP. Should be as many as NAT gateways
            response = ec2_client.describe_addresses(
                Filters=[{"Name": "domain", "Values": ["vpc"]}],
            )
            assert len(response["Addresses"]) == expected_nat_gateways_count

            assert len(tf_out["subnets_all"]["value"]) == expected_subnet_all_count
            assert (
                len(tf_out["subnets_public"]["value"]) == expected_subnet_public_count
            )
            assert (
                len(tf_out["subnets_private"]["value"]) == expected_subnet_private_count
            )
