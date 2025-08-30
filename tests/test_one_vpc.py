from pprint import pformat, pprint

from os import path as osp, remove
from textwrap import dedent

import pytest
from infrahouse_core.aws.ec2_instance import EC2Instance
from infrahouse_toolkit.terraform import terraform_apply

from tests.conftest import create_tf_conf, TERRAFORM_ROOT_DIR


@pytest.mark.parametrize(
    "aws_provider_version", ["~> 5.11", "~> 6.0"], ids=["aws-5", "aws-6"]
)
@pytest.mark.parametrize(
    ", ".join(
        [
            "management_cidr_block",
            "vpc_cidr_block",
            "subnets",
            "expected_nat_gateways_count",
            "expected_subnet_all_count",
            "expected_subnet_public_count",
            "expected_subnet_private_count",
            "restrict_all_traffic",
            "enable_vpc_flow_logs",
        ]
    ),
    [
        # One VPC with no subnets
        (
            "10.0.0.0/16",
            "10.0.0.0/16",
            "[]",
            0,  # expected_nat_gateways_count
            0,  # expected_subnet_all_count
            0,  # expected_subnet_public_count
            0,  # expected_subnet_private_count
            False,  # restrict_all_traffic
            False,  # enable_vpc_flow_logs
        ),
        # One VPC with no subnets, restrict all traffic
        (
            "10.0.0.0/16",
            "10.0.0.0/16",
            "[]",
            0,  # expected_nat_gateways_count
            0,  # expected_subnet_all_count
            0,  # expected_subnet_public_count
            0,  # expected_subnet_private_count
            True,  # restrict_all_traffic
            False,  # enable_vpc_flow_logs
        ),
        # One VPC with one subnet
        (
            "192.168.0.0/24",
            "192.168.0.0/24",
            """
            [
                {{
                    cidr                    = "192.168.0.0/24"
                    availability-zone       = "{zone_a}"
                    map_public_ip_on_launch = true
                    create_nat              = false
                    forward_to              = null
                }}
            ]
            """,
            0,  # expected_nat_gateways_count
            1,  # expected_subnet_all_count
            1,  # expected_subnet_public_count
            0,  # expected_subnet_private_count
            False,  # restrict_all_traffic
            False,  # enable_vpc_flow_logs
        ),
        # One VPC with three subnets
        (
            "10.1.0.0/16",
            "10.1.0.0/16",
            """[
                {{
                    cidr                    = "10.1.0.0/24"
                    availability-zone       = "{zone_a}"
                    map_public_ip_on_launch = true
                    create_nat              = true
                    forward_to              = null
                }},
                {{
                    cidr                    = "10.1.1.0/24"
                    availability-zone       = "{zone_b}"
                    map_public_ip_on_launch = false
                    create_nat              = false
                    forward_to              = "10.1.0.0/24"
                }},
                {{
                    cidr                    = "10.1.2.0/24"
                    availability-zone       = "{zone_c}"
                    map_public_ip_on_launch = false
                    create_nat              = false
                    forward_to              = "10.1.0.0/24"
                }}
            ]
            """,
            1,  # expected_nat_gateways_count
            3,  # expected_subnet_all_count
            1,  # expected_subnet_public_count
            2,  # expected_subnet_private_count
            True,  # restrict_all_traffic
            True,  # enable_vpc_flow_logs
        ),
        # One VPC with four subnets and one NAT gateway
        (
            "10.1.0.0/16",
            "10.1.0.0/16",
            """[
                    {{
                      cidr                    = "10.1.0.0/24"
                      availability-zone       = "{zone_a}"
                      map_public_ip_on_launch = true
                      create_nat              = true
                    }},
                    {{
                      cidr                    = "10.1.1.0/24"
                      availability-zone       = "{zone_a}"
                      forward_to              = "10.1.0.0/24"
                    }},
                    {{
                      cidr                    = "10.1.2.0/24"
                      availability-zone       = "{zone_b}"
                      map_public_ip_on_launch = true
                    }},
                    {{
                      cidr                    = "10.1.3.0/24"
                      availability-zone       = "{zone_b}"
                      forward_to              = "10.1.0.0/24"
                    }}
                  ]
                  """,
            1,  # expected_nat_gateways_count
            4,  # expected_subnet_all_count
            2,  # expected_subnet_public_count
            2,  # expected_subnet_private_count
            True,  # restrict_all_traffic
            False,  # enable_vpc_flow_logs
        ),
    ],
)
def test_service_network(
    aws_provider_version,
    management_cidr_block,
    vpc_cidr_block,
    subnets,
    expected_nat_gateways_count,
    expected_subnet_all_count,
    expected_subnet_public_count,
    expected_subnet_private_count,
    restrict_all_traffic,
    enable_vpc_flow_logs,
    keep_after,
    test_role_arn,
    boto3_session,
    aws_region,
):
    terraform_module_dir = osp.join(TERRAFORM_ROOT_DIR, "service_network")

    # Delete .terraform.lock.hcl to allow provider version changes
    lock_file_path = osp.join(terraform_module_dir, ".terraform.lock.hcl")
    try:
        remove(lock_file_path)
    except FileNotFoundError:
        pass

    terraform_tf_path = osp.join(terraform_module_dir, "terraform.tf")
    with open(terraform_tf_path, "w") as fp:
        fp.write(
            dedent(
                f"""
                    terraform {{
                      required_providers {{
                        aws = {{
                          source  = "hashicorp/aws"
                          version = "{aws_provider_version}"
                        }}
                        random = {{
                         source  = "hashicorp/random"
                         version = "~> 3.7"
                        }}
                      }}
                    }}
                    """
            )
        )

    ec2 = boto3_session.client("ec2", region_name=aws_region)
    response = ec2.describe_availability_zones(
        Filters=[
            {"Name": "state", "Values": ["available"]},
            {"Name": "zone-type", "Values": ["availability-zone"]},
        ]
    )
    zone_names = [z["ZoneName"] for z in response["AvailabilityZones"]]

    with create_tf_conf(
        tf_dir=terraform_module_dir,
        region=aws_region,
        management_cidr_block=management_cidr_block,
        vpc_cidr_block=vpc_cidr_block,
        subnets=subnets,
        restrict_all_traffic=restrict_all_traffic,
        enable_vpc_flow_logs=enable_vpc_flow_logs,
        test_role_arn=test_role_arn,
        zone_names=zone_names,
    ):
        with terraform_apply(
            terraform_module_dir,
            json_output=True,
            var_file="terraform.tfvars",
            destroy_after=not keep_after,
        ) as tf_out:
            test_id = tf_out["test_id"]["value"]
            response = ec2.describe_vpcs(
                Filters=[
                    {"Name": "state", "Values": ["available"]},
                    {"Name": "cidr", "Values": [vpc_cidr_block]},
                    {"Name": "vpc-id", "Values": [tf_out["vpc_id"]["value"]]},
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
            response = ec2.describe_internet_gateways(
                Filters=[
                    {"Name": "attachment.vpc-id", "Values": [vpc_id]},
                    {"Name": "attachment.state", "Values": ["available"]},
                ],
            )
            assert len(response["InternetGateways"]) == 1

            # Check NAT gateway
            response = ec2.describe_nat_gateways(
                Filters=[
                    {"Name": "state", "Values": ["available"]},
                    {"Name": "vpc-id", "Values": [vpc_id]},
                ],
            )
            assert len(response["NatGateways"]) == expected_nat_gateways_count

            # Check Elastic IP. Should be as many as NAT gateways
            response = ec2.describe_addresses(
                Filters=[
                    {"Name": "domain", "Values": ["vpc"]},
                    {"Name": "tag:test_id", "Values": [test_id]},
                ],
            )
            assert len(response["Addresses"]) == expected_nat_gateways_count

            assert len(tf_out["subnets_all"]["value"]) == expected_subnet_all_count
            assert (
                len(tf_out["subnets_public"]["value"]) == expected_subnet_public_count
            )
            assert (
                len(tf_out["subnets_private"]["value"]) == expected_subnet_private_count
            )
            for instance_id in tf_out["client_instances"]["value"]:
                assert (
                    EC2Instance(
                        instance_id=instance_id,
                        region=aws_region,
                        role_arn=test_role_arn,
                    ).execute_command("ping -c 1 google.com")[0]
                    == 0
                )
