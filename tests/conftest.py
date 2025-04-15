import logging
from contextlib import contextmanager
from os import path as osp

import boto3
import pytest
from textwrap import dedent

from infrahouse_toolkit.logging import setup_logging

# "303467602807" is our test account
TEST_ACCOUNT = "303467602807"
# TEST_ROLE_ARN = "arn:aws:iam::303467602807:role/service-network-tester"
DEFAULT_PROGRESS_INTERVAL = 10


LOG = logging.getLogger(__name__)
setup_logging(LOG, debug=True)


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
    enable_vpc_flow_logs: bool = False,
    test_role_arn: str = None
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
                    enable_vpc_flow_logs = {str(enable_vpc_flow_logs).lower()}
                    """
                )
            )
            fd.write(f"subnets = {subnets}")
            if test_role_arn:
                fd.write(
                    dedent(
                        f"""
                        role_arn      = "{test_role_arn}"
                        """
                    )
                )

        LOG.info(
            "Terraform configuration: %s",
            open(osp.join(tf_dir, "terraform.tfvars")).read(),
        )
        yield
    finally:
        pass
        # os.remove(config_file)
