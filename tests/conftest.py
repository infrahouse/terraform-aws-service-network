import logging
from contextlib import contextmanager
from os import path as osp

import boto3
import pytest
from textwrap import dedent

from infrahouse_toolkit.logging import setup_logging

# "303467602807" is our test account
TEST_ACCOUNT = "303467602807"
TEST_ROLE_ARN = "arn:aws:iam::303467602807:role/service-network-tester"
DEFAULT_PROGRESS_INTERVAL = 10
TRACE_TERRAFORM = False


def pytest_addoption(parser):
    parser.addoption(
        "--keep-after",
        action="store_true",
        default=False,
        help="If specified, don't destroy resources",
    )


@pytest.fixture(scope="session")
def keep_after(request):
    return request.config.getoption("--keep-after")


LOG = logging.getLogger(__name__)
setup_logging(LOG, debug=True)


@pytest.fixture(scope="session")
def aws_iam_role():
    sts = boto3.client("sts")
    return sts.assume_role(
        RoleArn=TEST_ROLE_ARN, RoleSessionName="terraform-aws-service-network-tester"
    )


@pytest.fixture(scope="session")
def boto3_session(aws_iam_role):
    return boto3.Session(
        aws_access_key_id=aws_iam_role["Credentials"]["AccessKeyId"],
        aws_secret_access_key=aws_iam_role["Credentials"]["SecretAccessKey"],
        aws_session_token=aws_iam_role["Credentials"]["SessionToken"],
    )


@pytest.fixture(scope="session")
def ec2_client(boto3_session):
    assert boto3_session.client("sts").get_caller_identity()["Account"] == TEST_ACCOUNT
    return boto3_session.client("ec2", region_name="us-east-2")


@pytest.fixture(scope="session")
def ec2_client_map(ec2_client, boto3_session):
    regions = [reg["RegionName"] for reg in ec2_client.describe_regions()["Regions"]]
    ec2_map = {reg: boto3_session.client("ec2", region_name=reg) for reg in regions}

    return ec2_map


def update_source(path, module_path):
    lines = open(path).readlines()
    with open(path, "w") as fp:
        for line in lines:
            line = line.replace("%SOURCE%", module_path)
            fp.write(line)


@contextmanager
def create_tf_conf(
    tf_dir,
    region,
    management_cidr_block,
    vpc_cidr_block,
    subnets,
    restrict_all_traffic: bool,
):
    config_file = osp.join(tf_dir, "terraform.tfvars")
    try:
        with open(config_file, "w") as fd:
            fd.write(
                dedent(
                    f"""
                    region = "{region}"
                    management_cidr_block = "{management_cidr_block}"
                    vpc_cidr_block = "{vpc_cidr_block}"
                    restrict_all_traffic = {str(restrict_all_traffic).lower()}
                    """
                )
            )
            fd.write(f"subnets = {subnets}")
        LOG.info(
            "Terraform configuration: %s",
            open(osp.join(tf_dir, "terraform.tfvars")).read(),
        )
        yield
    finally:
        pass
        # os.remove(config_file)
